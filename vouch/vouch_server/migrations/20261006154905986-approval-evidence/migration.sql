BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "approval" ADD COLUMN "transcriptMatch" text;
ALTER TABLE "approval" ADD COLUMN "heardTranscript" text;
ALTER TABLE "approval" ADD COLUMN "transcriptSimilarity" double precision;
ALTER TABLE "approval" ADD COLUMN "requiredTier" text;
ALTER TABLE "approval" ADD COLUMN "presentTier" text;
ALTER TABLE "approval" ADD COLUMN "policyReason" text;
ALTER TABLE "approval" ADD COLUMN "ruleSource" text;

--
-- MIGRATION VERSION FOR vouch
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vouch', '20261006154905986-approval-evidence', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261006154905986-approval-evidence', "timestamp" = now();

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
