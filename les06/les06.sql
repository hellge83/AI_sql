use vk;

-- update profiles set photo_id = FLOOR(1 + (RAND() * 100));
update profiles set photo_id = (select media.id from media where media_type_id = 1 and profiles.user_id = media.user_id);
select * from profiles;

CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- data from fill db
-- INSERT INTO `posts` VALUES ('1','12','16','quo','Cumque cupiditate dolorem laboriosam cumque. Consectetur laboriosam quis natus quasi. Officiis vero inventore sunt culpa fuga eius.','0','1970-01-01 00:00:00','1970-01-01 00:00:00'),

update posts set community_id = NULL where community_id = 0;
update posts set user_id = FLOOR(1 + RAND() * 100) where user_id = 0;
update posts set media_id = NULL where media_id = 0;
update posts set created_at = FROM_UNIXTIME(RAND() * (UNIX_TIMESTAMP('2020-01-01') - UNIX_TIMESTAMP('2010-01-01')) + UNIX_TIMESTAMP('2010-01-01'));

-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

-- Заполняем лайки
INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

-- Проверим
SELECT * FROM likes LIMIT 10;

alter table communities_users 
	add constraint communities_users_community_id_fk
		foreign key (community_id) references communities(id),
	add constraint communities_users_user_id_fk
		foreign key (community_id) references users(id);

alter table friendship 
	add constraint friendship_user_id_fk
		foreign key (user_id) references users(id),
	add constraint friendship_friend_id_fk
		foreign key (friend_id) references users(id),
	add constraint friendship_status_id_fk
		foreign key (status_id) references friendship_statuses(id);	

alter table media 
	add constraint media_media_type_id_fk
		foreign key (media_type_id) references media_types(id),
	add constraint media_user_id_fk
		foreign key (user_id) references users(id);

alter table messages 
	add constraint messages_from_user_id_fk
		foreign key (from_user_id) references users(id),
	add constraint messages_to_user_id_fk
		foreign key (to_user_id) references users(id),		
	add constraint messages_community_id_fk
		foreign key (community_id) references communities(id);
	
alter table likes 
	add constraint likes_user_id_fk
		foreign key (user_id) references users(id),
	add constraint likes_target_id_fk
		foreign key (target_id) references users(id),		
	add constraint likes_target_type_id_fk
		foreign key (target_type_id) references target_types(id);	
	
alter table posts 
	add constraint posts_user_id_fk
		foreign key (user_id) references users(id),
	add constraint posts_community_id_fk
		foreign key (community_id) references communities(id),		
	add constraint posts_media_id_fk
		foreign key (media_id) references media(id);		
	
alter table profiles 
	add constraint profiles_user_id_fk
		foreign key (user_id) references users(id),
	add constraint profiles_photo_id_fk
		foreign key (photo_id) references media(id);	
	

-- task 3
with  top10 as (
select 
distinct user_id
, (select birthday from profiles p where l.user_id = p.user_id) as bday
from likes l
order by 2 desc limit 10 
)

select count(id) from likes l2
where l2.user_id in (select user_id from top10);

-- task 4	
select 
(select gender from profiles p where l.user_id = p.user_id) as gender
, count(user_id) as qty
from likes l
group by 1;


-- task 5 
select 
id
, (select count(id) from likes l where u.id=l.user_id) + (select count(id) from posts p where u.id=p.user_id) + (select count(id) from messages m where u.id=m.from_user_id) as activity
, least((select coalesce(max(created_at), '2020-06-01') from likes l where u.id=l.user_id), (select coalesce(max(created_at), '2020-06-01') from posts p where u.id=p.user_id), (select coalesce(max(created_at), '2020-06-01') from messages m where u.id=m.from_user_id)) as min_lastdate
from users u
order by activity, min_lastdate
limit 10;

