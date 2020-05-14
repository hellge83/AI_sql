use shop;

INSERT INTO orders (user_id, created_at, updated_at) VALUES
  (1, now(), now()),
  (2, now(), now()),
  (3, now(), now()),
  (2, now(), now()),
  (2, now(), now()),
  (3, now(), now());
 
-- task 1 
select distinct 
-- o.user_id, 
u.name
from orders o 
join users u 
on o.user_id=u.id;

-- task 2
select p.name as product, c.name as category
from products p
join catalogs c
on p.catalog_id = c.id;

-- task 3
create table flights (
  id serial primary key,
  from_c VARCHAR(255),
  to_c VARCHAR(255)
);

insert into flights (from_c, to_c) values 
('moscow', 'omsk'), 
('novgorod', 'kazan'), 
('irkutsk', 'moscow'), 
('omsk', 'irkutsk'), 
('moscow', 'kazan');

create table cities (
  label VARCHAR(255),
  name VARCHAR(255)
);

insert into cities (label, name) values
('moscow', 'Москва'), 
('irkutsk', 'Иркутск'), 
('novgorod', 'Новгород'),
('kazan', 'Казань'),
('omsk', 'Омск');


select c1.name as from_name, c2.name as to_name
from flights f
join cities c1
on f.from_c=c1.label
join cities c2
on f.to_c=c2.label
order by f.id;

drop table flights;
drop table cities;