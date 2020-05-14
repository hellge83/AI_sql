use vk;

-- task 1
with top10 as (select 
	user_id 
from profiles p
order by p.birthday desc
limit 10
)

select 
	count(likes.id)
from top10
left join likes 
	on top10.user_id = likes.target_id 
where target_type_id = 2;

-- task 2
select 
	p.gender 
	, count(id) as qty
from likes l
join profiles p
	on l.user_id = p.user_id 
group by 1

-- task 3
select u.id 
, count(l.id) + count(p.id) + count(m.id) as activity
, greatest(coalesce(max(l.created_at), '1900-01-01'), coalesce(max(p.created_at), '1900-01-01'), coalesce(max(m.created_at), '1900-01-01')) as last_activity
from users u
left join likes l
	on u.id = l.user_id 
left join posts p
	on u.id = p.user_id 
left join messages m
	on u.id = m.from_user_id 
group by 1
order by activity, last_activity
limit 10;


