BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "demo_household" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "hubId" bigint NOT NULL,
    "ownerAuthUserId" text NOT NULL,
    "hubPrivateKeySeed" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "demo_household_household_idx" ON "demo_household" USING btree ("householdId");
CREATE UNIQUE INDEX "demo_household_owner_idx" ON "demo_household" USING btree ("ownerAuthUserId");
CREATE INDEX "demo_household_created_idx" ON "demo_household" USING btree ("createdAt");


--
-- MIGRATION VERSION FOR vouch
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vouch', '20261019204456969-demo-household', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261019204456969-demo-household', "timestamp" = now();

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
