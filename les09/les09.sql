-- task 06_01
truncate table sample.users;

start transaction;
insert into sample.users (name, birthday_at)
	select name, birthday_at from shop.users 
	where id = 2;
delete from shop.users where id = 2;
commit;

-- task 06_02
use shop;

create view product_to_catalog as 
	select 
	p.name as product_name
	, c.name as catalog_name
	from shop.products p 
	join catalogs c 
	on p.catalog_id = c.id;

-- task 06_03
drop table if exists dates;
create table dates (
created_at DATETIME
);
insert into dates (created_at) values
('2018-08-01'), ('2018-08-04'), ('2018-08-16'), ('2018-08-17');

with aug as (select 
adddate('2018-08-01', interval (6*(a-1)+ b -1) day) as dt 
from (select 1 a union all select 2 union all select 3 union all select 4 union all select 5 union all select 6) x 
CROSS JOIN
(select 1 b union all select 2 union all select 3 union all select 4 union all select 5 union all select 6) y 
where 6*(a-1)+ b -1 <= 30
)

select dt
, case when created_at is null then 0 else 1 end as dt_exists
from aug
left join dates on
aug.dt = dates.created_at 
order by 1
;
drop table dates;

-- task 06_04
drop table if exists dates;
create table dates (
created_at DATETIME
);
insert into dates (created_at) values
('2018-08-01'), ('2018-08-04'), ('2018-08-27'), ('2018-08-10'), ('2018-08-12'), ('2018-08-16'), ('2018-08-17');

start transaction;
	create temporary table top5 (
	created_at DATETIME
	);
	insert into top5 (created_at)
		select created_at from dates order by 1 desc limit 5;
	
	
	delete from dates where created_at not in (select * from top5);
	drop table top5;
commit;

-- select * from dates
-- drop table top5;
-- drop table dates;



-- task 08_01
delimiter //
drop procedure if exists hello//
create procedure hello ()
begin
	case 
	when CURRENT_TIME() between '06:00:00' and '11:59:59'
	then select 'good morning';
	when CURRENT_TIME() between '12:00:00' and '17:59:59'
	then select 'good day';
	when CURRENT_TIME() between '18:00:00' and '23:59:59'
	then select 'good evening';
	when CURRENT_TIME() between '00:00:00' and '15:59:59'
	then select 'good night';
	end case;
end//
delimiter ;
call hello();


-- task 08_02
delimiter //
drop trigger if exists check_name_desc//
create trigger check_name_desc before insert on products
for each row
begin
	if coalesce(new.name, new.description) is null then
		signal sqlstate '45000' set MESSAGE_TEXT = 'INSERT canceled';
	end if;
end//
delimiter ;

insert into products (name, description, price, catalog_id) values
  (null, null, 5060.00, 2);

-- task 08_03
delimiter //
drop function if exists fibonacci//
create function fibonacci (num int)
returns int deterministic
begin
	declare i INT default 2;
	declare f int default 0;
	declare s int default 1;
	declare tmp int default 0;
	if num < 2 then
		return num;
	else
		while i < num + 1 DO
			set tmp = s;
			set s = f + s;
			set f = tmp;
			set i = i + 1;
		end while;
		return s;
	end if;
end// 
delimiter ;
select fibonacci(10);

-- task07_01
create user foo;
GRANT ALL ON shop.* TO 'foo'@'%';

mysql -u foo -p
show databases; -- information _schema and shop

create user bar;
GRANT select ON shop.* TO 'bar'@'%';
-- REVOKE ALL ON *.* FROM 'foo'@'%';
-- REVOKE ALL ON *.* FROM 'bar'@'%';
-- DROP USER foo;
-- DROP USER bar;

-- task07_02
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя пользователя',
  passwd VARCHAR(255) COMMENT 'Пароль пользователя'
) COMMENT = 'Пользователи';

INSERT INTO accounts (name, passwd) VALUES
  ('name1', 'pass1'),
  ('name2', 'pass2'),
  ('name3', 'pass3');
  
create view username as 
	select 
	id
	, name
	from accounts; 
	
create user user_read;
GRANT select ON shop.accounts TO 'user_read'@'%';
-- REVOKE ALL ON *.* FROM 'user_read'@'%';
-- drop user user_read;
-- drop table accounts;