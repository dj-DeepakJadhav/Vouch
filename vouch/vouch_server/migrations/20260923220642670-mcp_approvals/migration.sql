BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "approval" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "memberId" bigint,
    "action" text NOT NULL,
    "argsJson" text NOT NULL,
    "utterance" text NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "used" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "decidedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "approval_household_status_idx" ON "approval" USING btree ("householdId", "status");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "mcp_client" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "tokenHash" text NOT NULL,
    "label" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "revoked" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "mcp_client_token_hash_idx" ON "mcp_client" USING btree ("tokenHash");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "approval"
    ADD CONSTRAINT "approval_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "approval"
    ADD CONSTRAINT "approval_fk_1"
    FOREIGN KEY("memberId")
    REFERENCES "member"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "mcp_client"
    ADD CONSTRAINT "mcp_client_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR vouch
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vouch', '20260923220642670-mcp_approvals', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260923220642670-mcp_approvals', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
