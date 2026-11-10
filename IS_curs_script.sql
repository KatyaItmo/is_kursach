CREATE TYPE "object_status" AS ENUM (
	'active',
	'frozen',
	'blocked'
);

CREATE TYPE "user_role" AS ENUM (
	'user',
	'moder',
	'admin'
);

CREATE TYPE "visibility_type" AS ENUM (
	'private',
	'authorized',
	'public'
);

CREATE TYPE "relation_type" AS ENUM (
	'friendship',
	'romance',
	'enemies',
	'family',
	'married',
	'other'
);

CREATE TYPE "complain_type" AS ENUM (
	'spam',
	'insult',
	'copyright',
	'other'
);

CREATE TYPE "status_type" AS ENUM (
	'new',
	'accepted',
	'declined'
);

CREATE TYPE "pay_type_enum" AS ENUM (
	'internal',
	'external'
);

CREATE TABLE IF NOT EXISTS "objects" (
	"id" SERIAL NOT NULL,
	"status" OBJECT_STATUS NOT NULL,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "users" (
	"id" SERIAL NOT NULL,
	"object_id" INTEGER NOT NULL,
	"username" VARCHAR(100) NOT NULL UNIQUE,
	"password" VARCHAR(255) NOT NULL,
	"nickname" VARCHAR(100) NOT NULL,
	"email" VARCHAR(100) NOT NULL,
	"avatar_url" VARCHAR(255),
	"bio" TEXT,
	"role" user_role NOT NULL,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"last_active_at" TIMESTAMP NOT NULL,
	"visibility" visibility_type NOT NULL DEFAULT 'public',
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "publications" (
	"id" SERIAL NOT NULL,
	"object_id" INTEGER NOT NULL,
	"author_id" INTEGER NOT NULL,
	"text" TEXT,
	"is_likable" BOOLEAN NOT NULL DEFAULT true,
	"is_commentable" BOOLEAN NOT NULL DEFAULT true,
	"count_likes" INTEGER NOT NULL DEFAULT 0,
	"count_comments" INTEGER NOT NULL DEFAULT 0,
	"published_at" TIMESTAMP NOT NULL,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "characters" (
	"id" SERIAL NOT NULL,
	"object_id" INTEGER NOT NULL,
	"name" VARCHAR(100) NOT NULL,
	"avatar_url" VARCHAR(255),
	"author_id" INTEGER NOT NULL,
	"owner_id" INTEGER NOT NULL,
	"short_description" VARCHAR(255),
	"bio" TEXT,
	"usage_rules" TEXT NOT NULL DEFAULT 'по согласованию с автором и владельцем',
	"is_for_sale" BOOLEAN NOT NULL DEFAULT false,
	"price" DECIMAL,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"visible" visibility_type NOT NULL,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "relations" (
	"id" SERIAL NOT NULL,
	"first" INTEGER NOT NULL,
	"second" INTEGER NOT NULL,
	"type" relation_type NOT NULL,
	"description" VARCHAR(255),
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "worlds" (
	"id" SERIAL NOT NULL,
	"object_id" INTEGER NOT NULL,
	"name" VARCHAR(100) NOT NULL,
	"avatar_url" VARCHAR(255),
	"owner_id" INTEGER NOT NULL,
	"bio" TEXT,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "character_world" (
	"character_id" INTEGER NOT NULL,
	"world_id" INTEGER NOT NULL,
	PRIMARY KEY("character_id", "world_id")
);

CREATE TABLE IF NOT EXISTS "arts" (
	"id" SERIAL NOT NULL,
	"publication_id" INTEGER NOT NULL,
	"image_link" VARCHAR(255) NOT NULL,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "character_art" (
	"character_id" INTEGER NOT NULL,
	"art_id" INTEGER NOT NULL,
	PRIMARY KEY("character_id", "art_id")
);

CREATE TABLE IF NOT EXISTS "posts" (
	"id" SERIAL NOT NULL,
	"publication_id" INTEGER NOT NULL,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"visible" visibility_type NOT NULL,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "post_art" (
	"post_id" INTEGER NOT NULL,
	"art_id" INTEGER NOT NULL,
	PRIMARY KEY("post_id", "art_id")
);

CREATE TABLE IF NOT EXISTS "comments" (
	"id" SERIAL NOT NULL,
	"publication_id" INTEGER NOT NULL,
	"parent_publication" INTEGER NOT NULL,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"visible" visibility_type NOT NULL,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "complains" (
	"id" SERIAL NOT NULL,
	"author_id" INTEGER NOT NULL,
	"complain_object_id" INTEGER NOT NULL,
	"type" complain_type NOT NULL,
	"text" TEXT NOT NULL,
	"status" status_type NOT NULL DEFAULT 'new',
	"moderator_id" INTEGER NOT NULL,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "appeals" (
	"id" SERIAL NOT NULL,
	"author_id" INTEGER NOT NULL,
	"complain_id" INTEGER NOT NULL,
	"text" TEXT,
	"status" status_type NOT NULL DEFAULT 'new',
	"moderator_id" INTEGER NOT NULL,
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "purchase_requests" (
	"id" SERIAL NOT NULL,
	"author_id" INTEGER NOT NULL,
	"character_id" INTEGER NOT NULL,
	"message" TEXT,
	"status" status_type NOT NULL DEFAULT 'new',
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "deals" (
	"id" SERIAL NOT NULL,
	"character_id" INTEGER NOT NULL,
	"buyer_id" INTEGER NOT NULL,
	"seller_id" INTEGER NOT NULL,
	"sum" DECIMAL NOT NULL,
	"pay_type" pay_type_enum NOT NULL,
	"comment" VARCHAR(255),
	"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id")
);

ALTER TABLE "users"
ADD FOREIGN KEY("object_id") REFERENCES "objects"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "publications"
ADD FOREIGN KEY("object_id") REFERENCES "objects"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "publications"
ADD FOREIGN KEY("author_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "characters"
ADD FOREIGN KEY("object_id") REFERENCES "objects"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "characters"
ADD FOREIGN KEY("author_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "characters"
ADD FOREIGN KEY("owner_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "relations"
ADD FOREIGN KEY("first") REFERENCES "characters"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "relations"
ADD FOREIGN KEY("second") REFERENCES "characters"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "relations" 
ADD CONSTRAINT "check_not_self_relation" 
CHECK (first <> second);

ALTER TABLE "worlds"
ADD FOREIGN KEY("object_id") REFERENCES "objects"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "worlds"
ADD FOREIGN KEY("owner_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "character_world"
ADD FOREIGN KEY("character_id") REFERENCES "characters"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "character_world"
ADD FOREIGN KEY("world_id") REFERENCES "worlds"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "arts"
ADD FOREIGN KEY("publication_id") REFERENCES "publications"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "character_art"
ADD FOREIGN KEY("character_id") REFERENCES "characters"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "character_art"
ADD FOREIGN KEY("art_id") REFERENCES "arts"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "posts"
ADD FOREIGN KEY("publication_id") REFERENCES "publications"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "post_art"
ADD FOREIGN KEY("post_id") REFERENCES "posts"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "post_art"
ADD FOREIGN KEY("art_id") REFERENCES "arts"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "comments"
ADD FOREIGN KEY("publication_id") REFERENCES "publications"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "comments"
ADD FOREIGN KEY("parent_publication") REFERENCES "publications"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "complains"
ADD FOREIGN KEY("author_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "complains"
ADD FOREIGN KEY("complain_object_id") REFERENCES "objects"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "complains"
ADD FOREIGN KEY("moderator_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "appeals"
ADD FOREIGN KEY("author_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "appeals"
ADD FOREIGN KEY("complain_id") REFERENCES "complains"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "appeals"
ADD FOREIGN KEY("moderator_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "purchase_requests"
ADD FOREIGN KEY("author_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "purchase_requests"
ADD FOREIGN KEY("character_id") REFERENCES "characters"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "deals"
ADD FOREIGN KEY("character_id") REFERENCES "characters"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "deals"
ADD FOREIGN KEY("buyer_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "deals"
ADD FOREIGN KEY("seller_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;

-- смена владельца при успешной сделке --
CREATE OR REPLACE FUNCTION trg_fn_process_deal()
RETURNS TRIGGER AS $$
BEGIN
    -- Обновляем владельца персонажа и снимаем с продажи
    UPDATE "characters" 
    SET "owner_id" = NEW."buyer_id", 
        "is_for_sale" = false, 
        "price" = NULL 
    WHERE "id" = NEW."character_id";

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_deals_after_insert
AFTER INSERT ON "deals"
FOR EACH ROW EXECUTE FUNCTION trg_fn_process_deal();

CREATE OR REPLACE FUNCTION trg_fn_update_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE "publications" 
        SET "count_comments" = "count_comments" + 1 
        WHERE "id" = NEW."parent_publication";
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE "publications" 
        SET "count_comments" = "count_comments" - 1 
        WHERE "id" = OLD."parent_publication";
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_comments_count_change
AFTER INSERT OR DELETE ON "comments"
FOR EACH ROW EXECUTE FUNCTION trg_fn_update_comments_count();

CREATE OR REPLACE FUNCTION trg_fn_prevent_frozen_blocked_updates()
RETURNS TRIGGER AS $$
DECLARE
    curr_status OBJECT_STATUS;
BEGIN
    SELECT "status" INTO curr_status FROM "objects" WHERE "id" = OLD."object_id";

    IF curr_status IN ('frozen', 'blocked') THEN
        RAISE EXCEPTION 'Изменение запрещено: объект заблокирован или заморожен.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_prevent_edit
BEFORE UPDATE ON "users"
FOR EACH ROW EXECUTE FUNCTION trg_fn_prevent_frozen_blocked_updates();

CREATE TRIGGER trg_characters_prevent_edit
BEFORE UPDATE ON "characters"
FOR EACH ROW EXECUTE FUNCTION trg_fn_prevent_frozen_blocked_updates();

CREATE TRIGGER trg_worlds_prevent_edit
BEFORE UPDATE ON "worlds"
FOR EACH ROW EXECUTE FUNCTION trg_fn_prevent_frozen_blocked_updates();

CREATE TRIGGER trg_publications_prevent_edit
BEFORE UPDATE ON "publications"
FOR EACH ROW EXECUTE FUNCTION trg_fn_prevent_frozen_blocked_updates();



CREATE OR REPLACE FUNCTION trg_fn_update_user_activity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE "users" 
    SET "last_active_at" = CURRENT_TIMESTAMP 
    WHERE "id" = NEW."author_id";
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_publications_update_activity
AFTER INSERT ON "publications"
FOR EACH ROW EXECUTE FUNCTION trg_fn_update_user_activity();


CREATE OR REPLACE FUNCTION create_object_record()
RETURNS TRIGGER AS $$
DECLARE
    new_obj_id INTEGER;
BEGIN
    INSERT INTO "objects" ("status") VALUES ('active') RETURNING "id" INTO new_obj_id;

    NEW."object_id" := new_obj_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_bi 
BEFORE INSERT ON "users" 
FOR EACH ROW EXECUTE FUNCTION create_object_record();

CREATE TRIGGER trg_characters_bi 
BEFORE INSERT ON "characters" 
FOR EACH ROW EXECUTE FUNCTION create_object_record();

CREATE TRIGGER trg_worlds_bi 
BEFORE INSERT ON "worlds" 
FOR EACH ROW EXECUTE FUNCTION create_object_record();

CREATE TRIGGER trg_publications_bi 
BEFORE INSERT ON "publications" 
FOR EACH ROW EXECUTE FUNCTION create_object_record();


-- рега
CREATE OR REPLACE FUNCTION sp_register_user(
    p_username VARCHAR(100),
    p_password VARCHAR(255),
    p_nickname VARCHAR(100),
    p_email VARCHAR(100),
    p_avatar_url VARCHAR(255) DEFAULT NULL,
    p_bio TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    new_user_id INTEGER;
BEGIN

    IF EXISTS (SELECT 1 FROM "users" WHERE "username" = p_username) THEN
        RAISE EXCEPTION 'Ошибка регистрации: логин "%" уже занят.', p_username;
    END IF;

    INSERT INTO "users" (
        "object_id", "username", "password", "nickname", "email", 
        "avatar_url", "bio", "role", "last_active_at"
    ) 
    VALUES (
        0,
        p_username, p_password, p_nickname, p_email, 
        p_avatar_url, p_bio, 'user', CURRENT_TIMESTAMP
    )
    RETURNING "id" INTO new_user_id;

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql;


-- авторизация
CREATE OR REPLACE FUNCTION sp_authenticate_user(
    p_username VARCHAR(100),
    p_password VARCHAR(255)
)
RETURNS BOOLEAN AS $$
DECLARE
    v_user RECORD;
    v_obj_status OBJECT_STATUS;
BEGIN

    SELECT * INTO v_user FROM "users" WHERE "username" = p_username;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ошибка авторизации: пользователь не найден.';
    END IF;

    SELECT "status" INTO v_obj_status FROM "objects" WHERE "id" = v_user.object_id;
    IF v_obj_status <> 'active' THEN
        RAISE EXCEPTION 'Ошибка авторизации: аккаунт заблокирован или заморожен.';
    END IF;

    -- тут всё ок жто хэш
    IF v_user.password <> p_password THEN
        RAISE EXCEPTION 'Ошибка авторизации: неверный пароль.';
    END IF;

    UPDATE "users" SET "last_active_at" = CURRENT_TIMESTAMP WHERE "id" = v_user.id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- новый персонаж
CREATE OR REPLACE FUNCTION sp_create_character(
    p_user_id INTEGER,
    p_name VARCHAR(100),
    p_short_description VARCHAR(255),
    p_bio TEXT,
    p_usage_rules TEXT,
    p_visible visibility_type,
    p_avatar_url VARCHAR(255) DEFAULT NULL,
    p_is_for_sale BOOLEAN DEFAULT FALSE,
    p_price DECIMAL DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    new_char_id INTEGER;
BEGIN
    INSERT INTO "characters" (
        "object_id", "name", "avatar_url", "author_id", "owner_id", 
        "short_description", "bio", "usage_rules", "is_for_sale", "price", "visible"
    )
    VALUES (
        0, p_name, p_avatar_url, p_user_id, p_user_id,
        p_short_description, p_bio, p_usage_rules, p_is_for_sale, p_price, p_visible
    )
    RETURNING "id" INTO new_char_id;

    RETURN new_char_id;
END;
$$ LANGUAGE plpgsql;

-- изменение персонажа
CREATE OR REPLACE PROCEDURE sp_update_character(
    p_user_id INTEGER,
    p_char_id INTEGER,
    p_new_bio TEXT,
    p_new_visible visibility_type,
    p_is_for_sale BOOLEAN,
    p_price DECIMAL
) AS $$
DECLARE
    v_owner_id INTEGER;
BEGIN
    SELECT "owner_id" INTO v_owner_id FROM "characters" WHERE "id" = p_char_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Персонаж не найден.';
    END IF;

    IF v_owner_id <> p_user_id THEN
        RAISE EXCEPTION 'У вас нет прав на редактирование этого персонажа (вы не владелец).';
    END IF;

    UPDATE "characters"
    SET "bio" = p_new_bio,
        "visible" = p_new_visible,
        "is_for_sale" = p_is_for_sale,
        "price" = p_price
    WHERE "id" = p_char_id;
END;
$$ LANGUAGE plpgsql;

-- новый мир и привязка персонажа
CREATE OR REPLACE FUNCTION sp_create_world_with_character(
    p_user_id INTEGER,
    p_name VARCHAR(100),
    p_bio TEXT,
    p_character_id INTEGER,
    p_avatar_url VARCHAR(255) DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    new_world_id INTEGER;
    v_char_owner INTEGER;
BEGIN
    SELECT "owner_id" INTO v_char_owner FROM "characters" WHERE "id" = p_character_id;
    IF v_char_owner <> p_user_id THEN
        RAISE EXCEPTION 'Нельзя привязать чужого персонажа к своему миру.';
    END IF;

    -- Создаем мир
    INSERT INTO "worlds" ("object_id", "name", "avatar_url", "owner_id", "bio")
    VALUES (0, p_name, p_avatar_url, p_user_id, p_bio)
    RETURNING "id" INTO new_world_id;

    -- Привязываем перса
    INSERT INTO "character_world" ("character_id", "world_id")
    VALUES (p_character_id, new_world_id);

    RETURN new_world_id;
END;
$$ LANGUAGE plpgsql;


-- продажа (заявка на сделку)
CREATE OR REPLACE FUNCTION sp_request_purchase(
    p_buyer_id INTEGER,
    p_character_id INTEGER,
    p_message TEXT
)
RETURNS INTEGER AS $$
DECLARE
    new_req_id INTEGER;
    v_is_for_sale BOOLEAN;
    v_owner_id INTEGER;
BEGIN
    SELECT "is_for_sale", "owner_id" INTO v_is_for_sale, v_owner_id 
    FROM "characters" WHERE "id" = p_character_id;

    IF NOT v_is_for_sale THEN
        RAISE EXCEPTION 'Персонаж не выставлен на продажу.';
    END IF;

    IF v_owner_id = p_buyer_id THEN
        RAISE EXCEPTION 'Вы не можете купить собственного персонажа.';
    END IF;

    INSERT INTO "purchase_requests" ("author_id", "character_id", "message", "status")
    VALUES (p_buyer_id, p_character_id, p_message, 'new')
    RETURNING "id" INTO new_req_id;

    RETURN new_req_id;
END;
$$ LANGUAGE plpgsql;

-- Владелец подтверждает сделку по запросу
CREATE OR REPLACE FUNCTION sp_confirm_deal(
    p_owner_id INTEGER,
    p_request_id INTEGER,
    p_pay_type pay_type_enum,
    p_comment VARCHAR(255) DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_req RECORD;
    v_char RECORD;
    new_deal_id INTEGER;
BEGIN
    SELECT * INTO v_req FROM "purchase_requests" WHERE "id" = p_request_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запрос на покупку не найден.';
    END IF;

    SELECT * INTO v_char FROM "characters" WHERE "id" = v_req.character_id;

    IF v_char.owner_id <> p_owner_id THEN
        RAISE EXCEPTION 'У вас нет прав подтверждать продажу этого персонажа.';
    END IF;

    -- триггер trg_fn_process_deal
    -- обновит owner_id в characters, сбросит is_for_sale и обнулит цеун
    INSERT INTO "deals" ("character_id", "buyer_id", "seller_id", "sum", "pay_type", "comment")
    VALUES (v_char.id, v_req.author_id, p_owner_id, COALESCE(v_char.price, 0.00), p_pay_type, p_comment)
    RETURNING "id" INTO new_deal_id;

    UPDATE "purchase_requests" SET "status" = 'accepted' WHERE "id" = p_request_id;

    RETURN new_deal_id;
END;
$$ LANGUAGE plpgsql;


CREATE INDEX idx_characters_owner_id ON "characters"("owner_id");

CREATE INDEX idx_characters_author_id ON "characters"("author_id");

CREATE INDEX idx_characters_for_sale ON "characters"("is_for_sale") WHERE "is_for_sale" = true;


CREATE INDEX idx_purchase_requests_character_id ON "purchase_requests"("character_id");

CREATE INDEX idx_deals_character_id ON "deals"("character_id");

CREATE INDEX idx_character_world_world_id ON "character_world"("world_id");

CREATE INDEX idx_users_object_id ON "users"("object_id");
CREATE INDEX idx_worlds_object_id ON "worlds"("object_id");
CREATE INDEX idx_characters_object_id   ON "characters"("object_id");   
CREATE INDEX idx_publications_object_id ON "publications"("object_id");
