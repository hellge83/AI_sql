use vk;

-- task 2
with u_com as (select 
distinct c.name
, first_value(p.user_id) over (partition by c.name order by p.birthday ) as min_bday
, first_value(p.user_id) over (partition by c.name order by p.birthday desc) as max_bday
, count(name) over (partition by c.name) as c_qty
from communities_users cu
join profiles p on cu.user_id = p.user_id
join communities c on cu.community_id = c.id 
)

select
distinct uc.name
, sum(c_qty) over () / count(c_qty) over () avg_users
, concat(u1.first_name, ' ', u1.last_name) as oldest_user
, concat(u2.first_name, ' ', u2.last_name) as youngest_user
, c_qty as com_qty
, (select count(u1.id) from users u1) total_users
, c_qty / (select count(u1.id) from users u1) * 100 percent
from u_com uc
join users u1 on uc.min_bday = u1.id
join users u2 on uc.max_bday = u2.id

-- task 1

create unique index users_email_uq on users(email);

-- search by community name
create index communities_mname_idx on communities(name);

-- search by reg. date
create index users_created_at_idx on users(created_at);

-- search by full name
create index users_first_name_last_name_idx on users(first_name, last_name);

-- search by city, country, b-day
create index profiles_city_idx on profiles(city);
create index profiles_country_idx on profiles(country);
create index profiles_birthday_idx on profiles(birthday);

-- fresh media search
create index media_created_at on media(created_at);

-- fresh posts search
create index posts_created_at on posts(created_at);

-- for "added new friends" block
create index friendship_confirmed_at on friendship(confirmed_at);

