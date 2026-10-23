BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "pairing_code" (
    "id" bigserial PRIMARY KEY,
    "householdId" bigint NOT NULL,
    "codeHash" text NOT NULL,
    "ownerId" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "usedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "pairing_code_hash_idx" ON "pairing_code" USING btree ("codeHash");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "pairing_code"
    ADD CONSTRAINT "pairing_code_fk_0"
    FOREIGN KEY("householdId")
    REFERENCES "household"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR vouch
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vouch', '20260924012630198', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924012630198', "timestamp" = now();

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
