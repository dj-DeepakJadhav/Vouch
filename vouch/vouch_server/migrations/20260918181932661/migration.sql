BEGIN;

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
    "revoked" boolean NOT NULL
);

-- Indexes
CREATE INDEX "attestation_member_expires_idx" ON "attestation" USING btree ("memberId", "expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "audit_event" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "memberId" bigint,
    "eventType" text NOT NULL,
    "action" text NOT NULL,
    "decision" text NOT NULL,
    "tierRequired" text,
    "tierPresent" text,
    "reason" text NOT NULL,
    "confidence" double precision,
    "createdAt" timestamp without time zone NOT NULL,
    "metadata" text
);

-- Indexes
CREATE INDEX "audit_event_household_created_idx" ON "audit_event" USING btree ("householdId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "challenge" (
    "id" bigserial PRIMARY KEY,
    "memberId" bigint NOT NULL,
    "question" text NOT NULL,
    "answerHash" text NOT NULL,
    "contextSource" text NOT NULL,
    "issuedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "consumedAt" timestamp without time zone,
    "outcome" text
);

-- Indexes
CREATE INDEX "challenge_member_expires_idx" ON "challenge" USING btree ("memberId", "expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "enrolment" (
    "id" bigserial PRIMARY KEY,
    "memberId" bigint NOT NULL,
    "hubId" bigint NOT NULL,
    "embeddingRef" text NOT NULL,
    "qualityScore" double precision NOT NULL,
    "sampleCount" bigint NOT NULL,
    "enrolledAt" timestamp without time zone NOT NULL,
    "revokedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "enrolment_member_idx" ON "enrolment" USING btree ("memberId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "household" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hub" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "publicKey" text NOT NULL,
    "lastSeen" timestamp without time zone,
    "version" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "member" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "displayName" text NOT NULL,
    "role" text NOT NULL,
    "status" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "policy_rule" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "actionPattern" text NOT NULL,
    "requiredTier" text NOT NULL,
    "enabled" boolean NOT NULL
);

-- Indexes
CREATE INDEX "policy_rule_household_action_idx" ON "policy_rule" USING btree ("householdId", "actionPattern");

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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "audit_event"
    ADD CONSTRAINT "audit_event_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "audit_event"
    ADD CONSTRAINT "audit_event_fk_1"
    FOREIGN KEY("memberId")
    REFERENCES "member"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "challenge"
    ADD CONSTRAINT "challenge_fk_0"
    FOREIGN KEY("memberId")
    REFERENCES "member"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "enrolment"
    ADD CONSTRAINT "enrolment_fk_0"
    FOREIGN KEY("memberId")
    REFERENCES "member"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "enrolment"
    ADD CONSTRAINT "enrolment_fk_1"
    FOREIGN KEY("hubId")
    REFERENCES "hub"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "hub"
    ADD CONSTRAINT "hub_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "member"
    ADD CONSTRAINT "member_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "policy_rule"
    ADD CONSTRAINT "policy_rule_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR vouch
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vouch', '20260918181932661', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260918181932661', "timestamp" = now();

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
