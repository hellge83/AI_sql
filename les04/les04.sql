use vk;

SELECT * FROM communities;
DELETE FROM communities WHERE id > 20;


SELECT * FROM communities_users;
-- не обновлялись группы из=за primary key
ALTER TABLE communities_users DROP PRIMARY KEY;
UPDATE communities_users SET community_id = FLOOR(1 + RAND() * 20);
-- оставила только уникальные строки
CREATE TABLE temp LIKE communities_users;
INSERT INTO temp SELECT DISTINCT * FROM communities_users;
DROP TABLE communities_users;
RENAME TABLE temp TO communities_users;
-- добавила руками до 100 записей
insert into communities_users values (20, 5),(20, 24);
-- вернула primary key
ALTER TABLE communities_users ADD PRIMARY KEY (community_id, user_id);


TRUNCATE friendship_statuses;
INSERT INTO friendship_statuses (name) VALUES
  ('Requested'),
  ('Confirmed'),
  ('Rejected');
select * from friendship_statuses;

SELECT * FROM friendship LIMIT 10;
UPDATE friendship SET status_id = FLOOR(1 + RAND() * 3); 
update friendship set confirmed_at = date_add(requested_at, interval FLOOR(1 + RAND() * 180) day) WHERE requested_at > confirmed_at;

select * from media_types;
truncate media_types;
INSERT INTO media_types (name) VALUES
  ('photo'),
  ('video'),
  ('audio')
;


SELECT * FROM media LIMIT 10;
UPDATE media SET media_type_id = FLOOR(1 + RAND() * 3);
CREATE TEMPORARY TABLE exts (name VARCHAR(10));
INSERT INTO exts VALUES ('jpeg'), ('avi'), ('mprg'), ('png');
SELECT * FROM exts;
UPDATE media SET filename = CONCAT('https://dropbox/vk/',
  filename,
  '.',
  (SELECT name FROM exts ORDER BY RAND() LIMIT 1)
);
ALTER TABLE media RENAME COLUMN size TO file_size;
UPDATE media SET file_size = FLOOR(10000 + (RAND() * 1000000)) WHERE file_size < 1000;
UPDATE media SET metadata = CONCAT('{"owner":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
  '"}');  
ALTER TABLE media MODIFY COLUMN metadata JSON;
desc media;


SELECT * FROM users LIMIT 10;
UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE created_at > updated_at;

select * from profiles limit 10;
update profiles set gender='f' where gender='1';
update profiles set gender='m' where gender='2';
DESC profiles;

-- а мы заполняли photo_id?
ALTER TABLE profiles ADD COLUMN photo_id INT UNSIGNED AFTER country;


SELECT * FROM messages LIMIT 10;
-- от юзера ИЛИ другому юзеру ИЛИ сообществу:
UPDATE messages SET community_id=NULL WHERE to_user_id is not null;
UPDATE messages SET community_id = FLOOR(1 + RAND() * 20)  WHERE community_id is not null;