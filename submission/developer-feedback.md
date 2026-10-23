# Vouch development friction log

Observed during development on October 22, 2026. Vouch is an Alexa+ prototype with a self-hosted MCP server and a simulated client. These entries describe the two integration blockers we encountered and the changes that would have let us test further.

## 1. Alexa+ setup guides lead to tools participants cannot access

### Task and steps

We wanted to test a sensitive tool request that pauses for owner approval, completes after approval, and rejects a replay.

1. Read the Alexa+ add-on setup and MCP integration documentation.
2. Investigated the CLI and Local Inspector testing path.
3. Checked the hackathon FAQ to establish whether those tools were available to participants.

### Expected and actual result

We expected a test client or inspector that could call our MCP server. The hackathon FAQ confirms that the Alexa+ developer tools are restricted to selected partners and that participants cannot obtain access.

We could implement the MCP flow, but could not compare our approval continuation or tool arguments with a live Alexa+ client. Simulation remained a valid submission route. Live interoperability testing remained blocked.

Severity: High for live interoperability testing.

### Workaround and evidence

We built a Flutter client that sends real MCP requests to the backend and displays its decision trace. The demo exercises approval, tool execution and rejection of the same used approval. Client behaviour, speaker identity and the owner-phone interface are labelled as simulated.

The [demo instructions](../README.md#fastest-way-to-try-it-no-hub-no-mic) describe how to repeat the flow. The [hackathon FAQ](https://amazonappdev2026.devpost.com/details/faqs) documents the access restriction and simulation route.

### Requested change

Place the partner-access restriction before the first installation step in every affected setup guide. Link directly to the participant-supported testing route.

Provide a public reference client with a fixed approval fixture: initial request, pending response, approval continuation, successful completion, and replay rejection. Include expected messages and supported protocol capabilities. It could run entirely against synthetic data without a live Alexa account.

This would let us test the request lifecycle against an Amazon-maintained example and reserve live-device access for the parts that need it.

## 2. Bedrock invocation permission does not explain an account restriction

### Task and steps

We wanted Amazon Nova Micro to review the included synthetic household audit export.

1. Authenticated through the AWS CLI and checked model availability.
2. Simulated the principal's `bedrock:InvokeModel` permission; the result allowed invocation.
3. Checked account/model authorisation and applied Nova Micro inference quotas.
4. Attempted Converse calls in Frankfurt and Northern Virginia.

### Expected and actual result

We expected either an on-demand response or an error that identified the missing prerequisite. Calls returned `ValidationException: Operation not allowed`.

The account/model authorisation was `NOT_AUTHORIZED`, and applied Nova Micro inference quotas were zero. The allowed IAM result did not resolve the account-level restriction. These observations concern our account; they do not establish a service-wide failure.

Severity: High for the optional Bedrock integration. The core permission workflow continued to work.

### Workaround and evidence

We retained the optional Bedrock provider with its failure documented. For the working AWS addition, we implemented a deterministic Lambda reviewer with private S3 reports. That path can flag repeated denials and approval replay signals without model inference.

The [AWS setup guide](../jobs/nightly_review/AWS.md) explains this implementation. The [saved verification result](aws-verification.json) records a successful Lambda invocation and S3 download over synthetic data. Neither is evidence of successful Bedrock inference.

AWS's [InvokeModel troubleshooting guidance](https://repost.aws/knowledge-center/bedrock-invokemodel-api-error) includes the “Operation not allowed” error and directs account-access cases to AWS Support.

### Requested change

Show a preflight result in the model playground that separates IAM permission, account/model authorisation, regional availability and applied inference quota. For a restricted account with zero quota, show the restriction and a support link before the user attempts inference.

Include a copyable diagnostic summary with the region, model ID, error code and quota status. Exclude credentials and prompt content. This would give support the relevant access checks without requiring developers to assemble them from separate console pages.
