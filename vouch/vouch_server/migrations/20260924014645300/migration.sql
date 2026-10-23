BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "tool_classification" (
    "id" bigserial PRIMARY KEY,
    "toolName" text NOT NULL,
    "tier" text NOT NULL,
    "reason" text NOT NULL,
    "model" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "tool_classification_tool_name_idx" ON "tool_classification" USING btree ("toolName");


--
-- MIGRATION VERSION FOR vouch
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vouch', '20260924014645300', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924014645300', "timestamp" = now();

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
