// Conformance check of vouch_server's hand-rolled /mcp route (modern era,
// spec 2026-07-28) against the official @modelcontextprotocol/sdk
// TypeScript client (npm's latest published version at the time of
// writing is 1.30.1, which speaks the 2025-11-25 wire format for
// initialize/session handling but happens to interoperate with our modern
// tools/call shape closely enough for this smoke check — see the header
// comment history in git blame for the original caveat). Drives the full
// step-up round trip end to end against the LIVE dev server:
//   connect (initialize) -> listTools -> callTool(get_weather) [T0, no
//   attestation] -> callTool(unlock_front_door) [T2 -> approval_pending +
//   approvalRef] -> dev/approveAsOwner -> retry with approvalRef [success]
//   -> retry again with the SAME approvalRef [must fail, replay guard].
//
// Seeds its own household per run via POST /dev/seedDemoHousehold with a
// FRESH random 32-byte base64 hub public key each time — Hub.publicKey is
// UNIQUE, so a fixed dummy key collides across runs (this was the actual
// cause of the earlier "500 Internal Server Error", not a bug in the /mcp
// route).
//
// Usage:
//   node index.js
// Optional env:
//   API_URL (default http://localhost:8080)
//   MCP_URL (default http://localhost:8082/mcp)

import crypto from 'node:crypto';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StreamableHTTPClientTransport } from '@modelcontextprotocol/sdk/client/streamableHttp.js';

const apiUrl = process.env.API_URL ?? 'http://localhost:8080';
const mcpUrl = process.env.MCP_URL ?? 'http://localhost:8082/mcp';

async function callDev(method, args) {
  const res = await fetch(`${apiUrl}/dev/${method}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(args),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`dev/${method} failed: ${res.status} ${text}`);
  }
  return text ? JSON.parse(text) : null;
}

async function main() {
  console.log(`[conformance] seeding a fresh demo household ...`);
  const hubPublicKeyBase64 = crypto.randomBytes(32).toString('base64');
  const seed = await callDev('seedDemoHousehold', {
    ownerName: 'Conformance Owner',
    childName: 'Conformance Kid',
    hubPublicKeyBase64,
  });
  console.log('[conformance] seeded:', JSON.stringify(seed));
  const token = seed.mcpToken;
  const householdId = seed.householdId;

  const transport = new StreamableHTTPClientTransport(new URL(mcpUrl), {
    requestInit: {
      headers: { Authorization: `Bearer ${token}` },
    },
  });

  const client = new Client({ name: 'vouch-mcp-conformance', version: '0.0.1' });

  console.log(`[conformance] connecting to ${mcpUrl} ...`);
  await client.connect(transport);
  console.log('[conformance] initialize: OK');

  const tools = await client.listTools();
  console.log('[conformance] tools/list result:');
  console.log(JSON.stringify(tools, null, 2));

  const weather = await client.callTool({
    name: 'get_weather',
    arguments: { utterance: "what's the weather" },
  });
  console.log('[conformance] tools/call get_weather result:');
  console.log(JSON.stringify(weather, null, 2));
  if (weather.isError) {
    throw new Error('get_weather (T0) unexpectedly returned isError:true');
  }

  // unlock_front_door is T2, and PolicyEngine denies outright (never even
  // reaches step-up) for a speaker the server can't resolve at all (see
  // policy_engine.dart: "Unknown speaker: only T0 actions are permitted at
  // all"). So the owner must be a recognised speaker first -- issue a real
  // (dev-signed) attestation bound to this exact utterance before calling
  // the tool. Tier here is irrelevant for a T2 action (it always steps up
  // regardless of attested tier); t1 just satisfies "recognised".
  const unlockUtterance = 'unlock the front door';
  await callDev('issueTestAttestation', {
    hubId: seed.hubId,
    memberId: seed.ownerMemberId,
    tier: 't1',
    utterance: unlockUtterance,
  });

  console.log('[conformance] tools/call unlock_front_door (T2, expect approval_pending) ...');
  const pending = await client.callTool({
    name: 'unlock_front_door',
    arguments: { utterance: unlockUtterance },
  });
  console.log(JSON.stringify(pending, null, 2));

  const structured = pending.structuredContent;
  if (!structured || structured.status !== 'approval_pending' || !structured.approvalRef) {
    throw new Error(
      'unlock_front_door did not return structuredContent.approval_pending/approvalRef: ' +
        JSON.stringify(pending)
    );
  }
  const approvalRef = structured.approvalRef;
  console.log('[conformance] got approvalRef, length', approvalRef.length);

  console.log('[conformance] resolving pending approval id via dev/latestPendingApprovalId ...');
  const approvalId = await callDev('latestPendingApprovalId', { householdId });
  if (approvalId == null) {
    throw new Error('dev/latestPendingApprovalId returned null — no pending approval found');
  }
  console.log('[conformance] pending approval id:', approvalId);

  console.log('[conformance] approving as owner via dev/approveAsOwner ...');
  const approved = await callDev('approveAsOwner', { approvalId });
  console.log(JSON.stringify(approved, null, 2));

  console.log('[conformance] retrying unlock_front_door with approvalRef (expect success) ...');
  const success = await client.callTool({
    name: 'unlock_front_door',
    arguments: { utterance: unlockUtterance, approvalRef },
  });
  console.log(JSON.stringify(success, null, 2));
  if (success.isError) {
    throw new Error('retry with approved approvalRef unexpectedly returned isError:true');
  }

  console.log('[conformance] REPLAY: retrying again with the SAME approvalRef (expect failure) ...');
  const replay = await client.callTool({
    name: 'unlock_front_door',
    arguments: { utterance: unlockUtterance, approvalRef },
  });
  console.log(JSON.stringify(replay, null, 2));
  if (!replay.isError) {
    throw new Error('replayed approvalRef unexpectedly SUCCEEDED — replay guard is broken');
  }

  await client.close();
  console.log('[conformance] ALL CHECKS PASSED.');
}

main().catch((err) => {
  console.error('[conformance] FAILED:', err);
  process.exit(1);
});
