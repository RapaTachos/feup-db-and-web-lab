--para nao usar o schema 'public'
DROP SCHEMA IF EXISTS lbaw2153 CASCADE;
CREATE SCHEMA lbaw2153;
SET search_path TO lbaw2153;

DROP TYPE IF EXISTS "badge_type" CASCADE;
DROP TYPE IF EXISTS "status_type" CASCADE;
DROP TYPE IF EXISTS "review_type" CASCADE;

DROP TABLE IF EXISTS "users" CASCADE;
DROP TABLE IF EXISTS "moderators" CASCADE;
DROP TABLE IF EXISTS "administrators" CASCADE;
DROP TABLE IF EXISTS "questions" CASCADE;
DROP TABLE IF EXISTS "tags" CASCADE;
DROP TABLE IF EXISTS "question_tags" CASCADE;
DROP TABLE IF EXISTS "answers" CASCADE;
DROP TABLE IF EXISTS "comments" CASCADE;
DROP TABLE IF EXISTS "images" CASCADE;

DROP TABLE IF EXISTS "badges" CASCADE;
DROP TABLE IF EXISTS "user_badges" CASCADE;

DROP TABLE IF EXISTS "question_reviews" CASCADE;
DROP TABLE IF EXISTS "answer_reviews" CASCADE;
DROP TABLE IF EXISTS "comment_reviews" CASCADE;

CREATE TYPE "badge_type" AS ENUM ( 'gold', 'silver', 'bronze' );
CREATE TYPE "status_type" AS ENUM ( 'active', 'inactive', 'idle', 'doNotDisturb');
CREATE TYPE "review_type" AS ENUM ('like', 'dislike' );

CREATE DOMAIN "timestamp_t" AS TIMESTAMP NOT NULL DEFAULT NOW();
CREATE DOMAIN "email_t" AS VARCHAR(320) NOT NULL CHECK (VALUE LIKE '_%@_%._%');

CREATE TABLE "images"
(
    id   SERIAL PRIMARY KEY,
    path TEXT NOT NULL UNIQUE
);

CREATE TABLE "users"
(
    id               SERIAL PRIMARY KEY,

    username         VARCHAR(25)  NOT NULL UNIQUE CHECK ( length(username) >= 3 ),
    full_name        VARCHAR(100),
    email            email_t,
    password         TEXT         NOT NULL,

    status           status_type  NOT NULL DEFAULT 'active',
    bio              VARCHAR(300),
    location         VARCHAR(100),
    profile_image_id INTEGER REFERENCES "images" (id) ON UPDATE CASCADE,

    is_blocked       BOOLEAN      NOT NULL DEFAULT FALSE,

    created_at       timestamp_t,
    updated_at       timestamp_t,
    CONSTRAINT ck_updated_after_created CHECK ( updated_at >= created_at )
);

CREATE TABLE "moderators"
(
    user_id INTEGER PRIMARY KEY REFERENCES "users" (id) ON DELETE CASCADE
);

CREATE TABLE "administrators"
(
    user_id INTEGER PRIMARY KEY REFERENCES "users" (id) ON DELETE CASCADE
);

CREATE TABLE "questions"
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER        NOT NULL REFERENCES users (id) ON UPDATE CASCADE,

    title      VARCHAR(100)   NOT NULL CHECK ( length(title) >= 10 ),
    content    VARCHAR(10000) NOT NULL CHECK ( length(content) >= 10 ),
    views      BIGINT         NOT NULL DEFAULT 0 CHECK ( views >= 0 ),

    created_at timestamp_t,
    updated_at timestamp_t,
    CONSTRAINT ck_updated_after_created CHECK ( updated_at >= created_at )
);

CREATE TABLE "tags"
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL CHECK ( length(name) >= 1 )
);

CREATE TABLE "question_tags"
(
    PRIMARY KEY (question_id, tag_id),
    question_id INTEGER REFERENCES "questions" (id) ON UPDATE CASCADE,
    tag_id      INTEGER REFERENCES "tags" (id) ON UPDATE CASCADE
);

CREATE TABLE "answers"
(
    id          SERIAL PRIMARY KEY,

    user_id     INTEGER        NOT NULL REFERENCES users (id) ON UPDATE CASCADE,
    question_id INTEGER        NOT NULL REFERENCES questions (id) ON UPDATE CASCADE,
    CONSTRAINT ck_one_answer_per_user UNIQUE (user_id, question_id),

    content     VARCHAR(10000) NOT NULL CHECK ( length(content) >= 10 ),

    created_at  timestamp_t,
    updated_at  timestamp_t,
    CONSTRAINT ck_updated_after_created CHECK ( updated_at >= created_at )
);

-- Use ALTER to avoid "table doesn't exist" errors
ALTER TABLE "questions"
    ADD COLUMN
        accepted_answer_id INTEGER REFERENCES answers (id) ON UPDATE CASCADE;

CREATE TABLE "comments"
(
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER       NOT NULL REFERENCES users (id) ON UPDATE CASCADE,

    question_id INTEGER REFERENCES questions (id) ON UPDATE CASCADE,
    answer_id   INTEGER REFERENCES answers (id) ON UPDATE CASCADE,
    CONSTRAINT ck_belongs_to_question_xor_answer CHECK ( (question_id IS NULL) != (answer_id IS NULL) ),

    content     VARCHAR(1000) NOT NULL CHECK ( length(content) >= 2 ),

    created_at  timestamp_t,
    updated_at  timestamp_t,
    CONSTRAINT ck_updated_after_created CHECK ( updated_at >= created_at )
);

CREATE TABLE "badges"
(
    id       SERIAL PRIMARY KEY,
    type     badge_type   NOT NULL,
    title    VARCHAR(25)  NOT NULL CHECK ( length(title) >= 2 ),
    content  VARCHAR(100) NOT NULL,
    image_id INTEGER REFERENCES "images" (id) ON UPDATE CASCADE
);

CREATE TABLE "user_badges"
(
    PRIMARY KEY (user_id, badge_id),
    user_id    INTEGER REFERENCES "users" (id) ON UPDATE CASCADE,
    badge_id   INTEGER REFERENCES "badges" (id) ON UPDATE CASCADE,

    awarded_at timestamp_t
);

CREATE TABLE "question_reviews"
(
    PRIMARY KEY (user_id, question_id),
    user_id     INTEGER REFERENCES "users" (id) ON UPDATE CASCADE,
    question_id INTEGER REFERENCES "questions" (id) ON UPDATE CASCADE,

    type        review_type NOT NULL,
    reviewed_at timestamp_t
);

CREATE TABLE "answer_reviews"
(
    PRIMARY KEY (user_id, answer_id),
    user_id     INTEGER REFERENCES "users" (id) ON UPDATE CASCADE,
    answer_id   INTEGER REFERENCES "answers" (id) ON UPDATE CASCADE,

    type        review_type NOT NULL,
    reviewed_at timestamp_t
);

CREATE TABLE "comment_reviews"
(
    PRIMARY KEY (user_id, comment_id),
    user_id     INTEGER REFERENCES "users" (id) ON UPDATE CASCADE,
    comment_id  INTEGER REFERENCES "comments" (id) ON UPDATE CASCADE,

    type        review_type NOT NULL,
    reviewed_at timestamp_t
);

-- Indexes

CREATE INDEX user_question ON "questions" USING hash (user_id);
CREATE INDEX created_question ON "questions" USING btree (created_at);
CREATE INDEX updated_question ON "questions" USING btree (updated_at);
CLUSTER "questions" USING updated_question;

CREATE INDEX created_answer ON "answers" USING btree (created_at);
CREATE INDEX user_answer ON "answers" USING hash (user_id);
CREATE INDEX question_answer ON "answers" USING btree (question_id);
CLUSTER "answers" USING question_answer;

CREATE INDEX user_comment ON "comments" USING hash (user_id);
CREATE INDEX question_comment ON "comments" USING hash (question_id);
CREATE INDEX answer_comment ON "comments" USING hash (answer_id);
CREATE INDEX created_comment ON "comments" USING btree (created_at);
CLUSTER "comments" USING created_comment;

CREATE INDEX type_question_review ON "question_reviews" USING hash (type);
CREATE INDEX type_answer_review ON "answer_reviews" USING hash (type);
CREATE INDEX type_comment_review ON "comment_reviews" USING hash (type);

-- FTS Indexes

ALTER TABLE questions
    ADD COLUMN ts_vectors TSVECTOR;

CREATE FUNCTION questions_search_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.ts_vectors = (
                setweight(to_tsvector('english', NEW.title), 'A') ||
                setweight(to_tsvector('english', NEW.content), 'B')
            );
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF (NEW.title != OLD.title OR NEW.content != OLD.content) THEN
            NEW.ts_vectors = (
                    setweight(to_tsvector('english', NEW.title), 'A') ||
                    setweight(to_tsvector('english', NEW.content), 'B')
                );
        END IF;
    END IF;

    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER questions_search_update
    BEFORE INSERT OR UPDATE
    ON questions
    FOR EACH ROW
EXECUTE PROCEDURE questions_search_update();

CREATE INDEX search_idx ON questions USING gin (ts_vectors);

-- Triggers

-- TRIGGER01
-- The accepted answer of a question must belong to itself and not some other question
CREATE FUNCTION check_accepted() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NEW.accepted_answer_id IS NOT NULL AND
       NOT EXISTS(SELECT * FROM "answers" WHERE id = NEW.accepted_answer_id AND question_id = NEW.id) THEN
        RAISE EXCEPTION 'The answer (id: %) does not belong to this question (id: %)', NEW.accepted_answer_id, NEW.id;
    END IF;

    RETURN NEW;
END
$BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER check_accepted
    BEFORE INSERT OR UPDATE
    ON questions
    FOR EACH ROW
EXECUTE PROCEDURE check_accepted();

------------------------------------       Populate        --------------------------------------


INSERT INTO "users"(username, full_name, email, password, status, bio, location, is_blocked, created_at ,updated_at) VALUES
('lugaRythm', 'Rui Pinto', 'up420000042@up.pt', 'UVBB32WI99NK', 'doNotDisturb', '42 is the solution to all questions', 'Oiã', DEFAULT, DEFAULT, DEFAULT),
('sanchovies', 'Karim Badjoras', 'up196900001@up.pt', 'H6GW4LYEUVW8', 'idle', 'here to check typos only', 'Curral de Moinas', DEFAULT, DEFAULT, DEFAULT),
('jhonnyB', 'Jhonny Bravo', 'up197400007@up.pt', 'SZZV34N3H3NR', DEFAULT, 'suck at math...', 'Porto', DEFAULT, DEFAULT, DEFAULT),
('hunnidGrams', 'Filipe Gomes', 'up143300000@up.pt', 'QP7UARLVR17D', DEFAULT, 'ready to code! :)', 'Algarve', DEFAULT, DEFAULT, DEFAULT),
('megaLaife', 'Marco Oracio', 'up450089999@up.pt', 'PGG16THOBQ1X', DEFAULT, 'hello world', 'Kingston', DEFAULT, DEFAULT, DEFAULT),
('Robyte', 'Sir Rob', 'up133745382@up.pt', '1SI9FA476TQ6', DEFAULT, 'started doing CTFs for fun', 'London', DEFAULT, DEFAULT, DEFAULT),
('VioletsRblue', 'Karen Smith', 'up55489028@up.pt', '4NCZV7M20NLM', DEFAULT, 'flowers can cure any sad day', 'Punta Cana', DEFAULT, DEFAULT, DEFAULT),
('masterMind', 'Joaquim Rosa', 'up167207718@up.pt', '37UHW05SJ2ZO', DEFAULT, 'idk what i am doing here', 'Denver', DEFAULT, DEFAULT, DEFAULT),
('inspectora', 'Raquel Murillo', 'up05667339@up.pt', 'P5R0VNEDRN21', DEFAULT, 'have you seen "la casa de papel"?', 'Nairobi', DEFAULT, DEFAULT, DEFAULT),
('loremIpsum', 'Pain Itself', 'up000000000@up.pt', '90JJXPPWKMSM', DEFAULT, 'enough users, its LOREM IPSUM time', 'Rome', DEFAULT, DEFAULT, DEFAULT);

/*Administrator*/
INSERT INTO "administrators" (user_id) VALUES (1),(2);

/*Moderator*/
INSERT INTO "moderators" (user_id) VALUES (3),(4);

/*Question*/
INSERT INTO "questions"( user_id, title, content, views, created_at, updated_at) VALUES
(3,'Need help connecting to FEUP VPN', 'Greetings, can someone please help me connect to the VPN using mac?', 5, DEFAULT, DEFAULT),
(5,'What is the second derivative of (6x-5)^-2', 'Hmmm nothing to say here really... the title is self explanatory', 13, DEFAULT, DEFAULT),
(7,'Weird dream meaning', 'Does anyone know what it means when you dream about waterfalls?', 0, DEFAULT, DEFAULT),
(9,'Arraial de Engenharia', 'Sorry, this might be the wrong place to ask but does anyone knows where to buy tickets for the party?', 78, DEFAULT, DEFAULT),
(10,'What is a NullPointerException, and how do I fix it?', 'What methods/tools can be used to determine the cause so that you stop the exception from causing the program to terminate prematurely?', 27, DEFAULT, DEFAULT);

/*Answer*/
INSERT INTO "answers"( user_id, question_id, content, created_at, updated_at) VALUES
(2, 1, 'follow these steps https://www.up.pt/it/pt/servicos/redes-e-conetividade/vpn/configuracao-manual-mac-9a6b54b9', DEFAULT, DEFAULT),
(3, 2, 'have you tried using wolfram alfa?', DEFAULT, DEFAULT),
(4, 2, 'that is easy bro, -216/(6x-5)^4', DEFAULT, DEFAULT),
(5, 4, 'dont know, because of the new pandemic restrictions...', DEFAULT, DEFAULT);

/*Comment*/
INSERT INTO "comments"( user_id, question_id, answer_id, content, created_at, updated_at) VALUES
(2, 1, null, 'its having some problems today', DEFAULT, DEFAULT),
(3, null, 1, 'thanks a lot bro!', DEFAULT, DEFAULT),
(8, null, 4, 'i dont care! i wanna party!', DEFAULT, DEFAULT);

/*Images*/
INSERT INTO "images"(id, path) VALUES
(001, 'badge_pictures/1.png'),
(002, 'badge_pictures/2.png'),
(003, 'badge_pictures/3.png'),
(004, 'badge_pictures/4.png'),
(005, 'badge_pictures/5.png'),
(101, 'profile_pictures/101.png'),
(102, 'profile_pictures/102.png'),
(103, 'profile_pictures/103.png'),
(104, 'profile_pictures/104.png');

/*Badge*/
INSERT INTO "badges"( type, title, content, image_id ) VALUES
('bronze', 'Welcome :)', 'Achieved when you activate your account',1),
('bronze', 'UpDate', 'Awarded when you update your profile for the first time',2),
('silver', 'Casual writer', 'Answered or commented on 10 different questions',3),
('silver', 'Doubt Everything!', 'Asked at  least 10 questions',4),
('gold', 'SuperMan', 'Got the correct answer in 25 different questions',5);

/*USER BADGES*/
INSERT INTO "user_badges"( user_id, badge_id, awarded_at ) VALUES
(8,1,DEFAULT),
(8,2,DEFAULT),
(9,1,DEFAULT),
(9,2,DEFAULT);

/*CORRECT ANSWER*/
UPDATE "questions" SET accepted_answer_id = 1 WHERE id = 1;

/* Question / Answer / Comment Reviews */
INSERT INTO "question_reviews"( user_id, question_id, type, reviewed_at ) VALUES
( 7, 1, 'like', DEFAULT),
( 8, 1, 'dislike', DEFAULT);

INSERT INTO "answer_reviews"( user_id, answer_id, type, reviewed_at ) VALUES
( 9, 1, 'like', DEFAULT);

INSERT INTO "comment_reviews"( user_id, comment_id, type, reviewed_at ) VALUES
( 10, 1, 'like', DEFAULT);