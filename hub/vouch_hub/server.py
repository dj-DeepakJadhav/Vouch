"""Typed calls onto the Vouch Serverpod backend, via C1a's rpc.ServerpodRpcClient."""
from .rpc import ServerpodRpcClient, ServerpodRpcError

RpcError = ServerpodRpcError


class Serverpod:
    def __init__(self, base_url: str, client=None):
        self.c = client or ServerpodRpcClient(base_url)

    def seed_demo_household(self, owner, child, pub_b64):
        return self.c.call("dev", "seedDemoHousehold", {"ownerName": owner, "childName": child,
                                                        "hubPublicKeyBase64": pub_b64})

    def approve_as_owner(self, approval_id: int):
        return self.c.call("dev", "approveAsOwner", {"approvalId": int(approval_id)})

    def submit_attestation(self, **kw):
        return self.c.call("attestation", "submit", kw)

    def report_enrolment(self, **kw):
        return self.c.call("enrolment", "report", kw)

    def create_pairing_code(self, **kw):
        return self.c.call("pairing", "createCode", kw)
