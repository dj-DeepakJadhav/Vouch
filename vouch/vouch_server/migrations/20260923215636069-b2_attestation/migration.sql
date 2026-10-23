BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "attestation" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "attestation" (
    "id" bigserial PRIMARY KEY,
    "memberId" bigint NOT NULL,
    "tier" text NOT NULL,
    "issuedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "confidence" double precision NOT NULL,
    "spoofRisk" text NOT NULL,
    "hubSig" text NOT NULL,
    "singleUse" boolean NOT NULL,
    "consumedAt" timestamp without time zone,
    "revoked" boolean NOT NULL,
    "transcriptHash" text NOT NULL,
    "transcriptNormalised" text NOT NULL,
    "capturedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "attestation_member_expires_idx" ON "attestation" USING btree ("memberId", "expiresAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "attestation"
    ADD CONSTRAINT "attestation_fk_0"
    FOREIGN KEY("memberId")
    REFERENCES "member"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR vouch
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vouch', '20260923215636069-b2_attestation', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260923215636069-b2_attestation', "timestamp" = now();

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
