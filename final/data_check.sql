use ads;

-- log table
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
drop trigger if exists site_ins_log//
create trigger site_ins_log after insert on site
for each row
begin
	call log_archive('site', new.id, new.name);
end//
delimiter ;

delimiter //
drop trigger if exists dfp_account_ins_log//
create trigger dfp_account_ins_log after insert on dfp_account
for each row
begin
	call log_archive('dfp_account', new.id, new.name);
end//
delimiter ;

-- unique site trigger
-- Прверяем на уникальность пару сайт - юзер. 
delimiter //
drop trigger if exists check_site_name_user_id//
create trigger check_site_name_user_id before insert on site
for each row
begin
	if concat(new.name, new.user_id) in (select concat(name, user_id) from site s where (new.name = s.name and new.user_id = s.user_id)) then
		signal sqlstate '45000' set MESSAGE_TEXT = 'These site-user already exists';
	end if;
end//
delimiter ;
