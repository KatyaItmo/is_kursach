TRUNCATE TABLE 
    "objects",
    "users",
    "publications",
    "characters",
    "relations",
    "worlds",
    "character_world",
    "arts",
    "character_art",
    "posts",
    "post_art",
    "comments",
    "complains",
    "appeals",
    "purchase_requests",
    "deals"
RESTART IDENTITY CASCADE;

SELECT sp_register_user('admin_polina', 'hash_pass_1', 'Полина (Админ)', 'polina@admin.test', 'https://example.com/avatars/admin.png', 'Главный разработчик и администратор системы.');
UPDATE "users" SET "role" = 'admin' WHERE "username" = 'admin_polina';

SELECT sp_register_user('mod_alex', 'hash_pass_2', 'Алексей Модер', 'alex@moder.test', 'https://example.com/avatars/alex.png', 'Слежу за порядком и чистотой в каталоге.');
UPDATE "users" SET "role" = 'moder' WHERE "username" = 'mod_alex';

SELECT sp_register_user('creator_max', 'hash_pass_3', 'Макс ОС-мейкер', 'max@creator.test', 'https://example.com/avatars/max.png', 'Создаю оригинальных персонажей и вселенные.');
SELECT sp_register_user('art_Alisa', 'hash_pass_4', 'Алиса Художница', 'alisa@art.test', 'https://example.com/avatars/alisa.png', 'Рисую арты на заказ и для души.');
SELECT sp_register_user('lector_ivan', 'hash_pass_5', 'Иван Читатель', 'ivan@reader.test', NULL, 'Просто коллекционирую интересные миры.');

SELECT sp_create_character(3, 'Эфир', 'Космический странник из туманности', 'Длинная био про Эфира...', 'Можно рисовать, нельзя менять лор без спроса.', 'public', 'https://example.com/chars/ether.png', true, 1500.00);
SELECT sp_create_character(3, 'Селеста', 'Маг звездного света', 'Биография мага Селесты...', 'Свободно для коллабов.', 'public', 'https://example.com/chars/celesta.png', false, NULL);

SELECT sp_create_character(4, 'Ника', 'Кибернетическая неко-девочка', 'История создания кибер-неки...', 'Только с указанием авторства.', 'public', 'https://example.com/chars/nika.png', true, 3000.00);
SELECT sp_create_character(4, 'Тень', 'Таинственный лесной дух', 'Описание лесного духа...', 'Закрытый персонаж.', 'private', 'https://example.com/chars/shadow.png', false, NULL);

INSERT INTO "relations" ("first", "second", "type", "description") VALUES
(1, 2, 'friendship', 'Эфир и Селеста путешествуют вместе по галактике'),
(3, 4, 'other', 'Ника иногда пересекается с духом Тени в цифровом лесу');

SELECT sp_create_world_with_character(3, 'Небесный Архипелаг', 'Мир летающих островов и звездных рек.', 1, 'https://example.com/worlds/archipelago.png');
SELECT sp_create_world_with_character(4, 'Нео-Москва 2142', 'Киберпанк мегаполис с вечным дождем.', 3, 'https://example.com/worlds/neomoscow.png');

INSERT INTO "publications" ("author_id", "text", "is_likable", "is_commentable", "published_at") 
VALUES (3, 'Всем привет! Выложил нового персонажа Эфира на продажу. Оценивайте концепт!', true, true, CURRENT_TIMESTAMP);

INSERT INTO "posts" ("publication_id", "visible") VALUES (1, 'public');

INSERT INTO "arts" ("publication_id", "image_link") VALUES (1, 'https://example.com/arts/ether_concept.png');
INSERT INTO "character_art" ("character_id", "art_id") VALUES (1, 1);
INSERT INTO "post_art" ("post_id", "art_id") VALUES (1, 1);

INSERT INTO "publications" ("author_id", "text", "is_likable", "is_commentable", "published_at") 
VALUES (4, 'Новый арт с Никой в новом образе! Как вам цветовая гамма?', true, true, CURRENT_TIMESTAMP);

INSERT INTO "posts" ("publication_id", "visible") VALUES (2, 'public');

INSERT INTO "arts" ("publication_id", "image_link") VALUES (2, 'https://example.com/arts/nika_art.png');
INSERT INTO "character_art" ("character_id", "art_id") VALUES (3, 2);
INSERT INTO "post_art" ("post_id", "art_id") VALUES (2, 2);

INSERT INTO "publications" ("author_id", "text", "is_likable", "is_commentable", "published_at") 
VALUES (5, 'Очень крутой персонаж! Заберу в избранное.', true, false, CURRENT_TIMESTAMP);
INSERT INTO "comments" ("publication_id", "parent_publication", "visible") VALUES (3, 1, 'public');

INSERT INTO "complains" ("author_id", "complain_object_id", "type", "text", "status", "moderator_id") 
VALUES (5, 2, 'other', 'Кажется, тут слишком яркие цвета, режет глаза.', 'new', 2);

INSERT INTO "appeals" ("author_id", "complain_id", "text", "status", "moderator_id") 
VALUES (4, 1, 'Ничего не режет, это киберпанк стиль!', 'new', 2);

SELECT sp_request_purchase(5, 1, 'Здравствуйте! Очень хочу выкупить этого персонажа для своей истории.');

SELECT sp_confirm_deal(3, 1, 'internal', 'Успешная передача прав через внутреннюю систему.');
