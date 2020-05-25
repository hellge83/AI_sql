use shop;

-- task 1
drop table if exists logs;
create table logs (
	id int unsigned not null auto_increment,
	created_at datetime default current_timestamp on update current_timestamp,
	table_name varchar(255),
	primary_id bigint unsigned,
	name varchar(255),
	primary key (id)
) comment = 'log table' engine=archive;

delimiter //
drop procedure if exists log_archive//
create procedure log_archive (tbl varchar(255), p_id bigint, row_name varchar(255))
begin
	insert into logs (table_name, primary_id, name) values
	  (tbl, p_id, row_name);
end//
delimiter ;


delimiter //
drop trigger if exists users_ins_log//
create trigger users_ins_log after insert on users
for each row
begin
	call log_archive('users', new.id, new.name);
end//
delimiter ;

delimiter //
drop trigger if exists products_ins_log//
create trigger products_ins_log after insert on products
for each row
begin
	call log_archive('products', new.id, new.name);
end//
delimiter ;

delimiter //
drop trigger if exists catalogs_ins_log//
create trigger catalogs_ins_log after insert on catalogs
for each row
begin
	call log_archive('catalogs', new.id, new.name);
end//
delimiter ;

insert into users (name, birthday_at) values
	  ('test_user', '1900-01-01');
insert into catalogs (name) values
  ('test_catalog');
insert into products (name, description, price, catalog_id) values
  ('test_product', 'test_desc', 999999, 1);
  

-- task 2
drop table if exists users_tmp;
create table users_tmp (
  id serial primary key,
  name varchar(255),
  birthday_at date,
  created_at datetime default current_timestamp,
  updated_at datetime default current_timestamp on update current_timestamp
) comment = 'tmp_table';

insert into users_tmp (name, birthday_at) values
('test_user1', '1900-01-01'),
('test_user2', '1900-01-01'),
('test_user3', '1900-01-01'),
('test_user4', '1900-01-01'),
('test_user5', '1900-01-01'),
('test_user6', '1900-01-01'),
('test_user7', '1900-01-01'),
('test_user8', '1900-01-01'),
('test_user9', '1900-01-01'),
('test_user10', '1900-01-01');

insert into 
	users (name, birthday_at)
select fst.name, fst.birthday_at
from
  users_tmp as fst,
  users_tmp as snd,
  users_tmp as thd,
  users_tmp as fth,
  users_tmp as fif,
  users_tmp as sth;