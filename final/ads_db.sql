drop database if exists ads;
create database ads;

-- ad units table
drop table if exists ads.ad_unit;
create table ads.ad_unit
(
    id bigint not null,
    name varchar(255),
    code varchar(255),
    dfp_account_id bigint not null,
    site_id integer,
    is_active boolean not null default true,
    constraint ad_unit_pkey primary key (id)
);

    
-- prebid params for each ad unit/size/bidder
drop table if exists ads.ad_unit_prebid_config;
create table ads.ad_unit_prebid_config
(
    ad_unit_id bigint not null,
    size_id integer not null,
    bidder_id integer not null,
    params json,
    constraint ad_unit_prebid_config_pkey primary key (ad_unit_id, size_id, bidder_id)
);


-- available size table
drop table if exists ads.size;
create table ads.size
(
    id int not null auto_increment,
    name varchar(255),
    constraint size_pkey primary key (id)
);


-- ad unit size table
drop table if exists ads.ad_unit_size;
create table ads.ad_unit_size
(
    ad_unit_id bigint not null,
    size_id integer not null,
    is_active boolean not null default true,
    constraint ad_unit_size_pkey primary key (ad_unit_id, size_id)

);


-- dfp advertisers
drop table if exists ads.advertiser;
create table ads.advertiser
(
    id bigint not null,
    name varchar(255),
    dfp_account_id bigint not null,
    constraint advertiser_pkey primary key (id)
);


-- available bidders
drop table if exists ads.bidder;
create table ads.bidder
(
    id integer not null auto_increment,
    name varchar(255),
    code varchar(255),
    constraint bidder_pkey primary key (id)
);


-- creatives
drop table if exists ads.creative;
create table ads.creative
(
    id bigint not null,
    name varchar(255) not null,
    size_id integer not null,
    advertiser_id bigint not null,
    constraint creative_pkey primary key (id)
);


-- user dfp accounts
drop table if exists ads.dfp_account;
create table ads.dfp_account
(
    id bigint not null,
    user_id integer not null,
    name varchar(255) not null,
    constraint dfp_account_pkey primary key (id)
);


-- LineItems table
drop table if exists ads.line_item;
create table ads.line_item
(
    id bigint not null,
    name varchar(255) not null,
    order_id bigint not null,
    constraint line_item_pkey primary key (id)
);


-- lineitem targeting (ad units)
drop table if exists ads.line_item_ad_unit_targeting;
create table ads.line_item_ad_unit_targeting
(
    line_item_id bigint not null,
    ad_unit_id bigint not null,
    constraint line_item_ad_unit_targeting_pkey primary key (line_item_id, ad_unit_id)
);

	
-- lineitem creatives
drop table if exists ads.line_item_creative;
create table ads.line_item_creative
(
    line_item_id bigint not null,
    creative_id bigint not null,
    constraint line_item_creative_pkey primary key (line_item_id, creative_id)
);


-- lineitem key-value targeting
drop table if exists ads.line_item_targeting;
create table ads.line_item_targeting
(
    line_item_id bigint not null,
    targeting_value_id bigint not null,
    constraint line_item_targeting_pkey primary key (line_item_id, targeting_value_id)
);


-- insertion orders table
drop table if exists ads.orders;
create table ads.orders
(
    id bigint not null,
    name varchar(255) not null,
    advertiser_id bigint not null,
    constraint order_pkey primary key (id)
);


-- sites
drop table if exists ads.site;
create table ads.site
(
    id integer not null auto_increment,
    name varchar(255) not null,
    url varchar(255) not null,
    user_id integer not null, 
    prebid json,
    constraint site_pkey primary key (id)
);


-- prebid config by site
drop table if exists ads.site_prebid_config;
create table ads.site_prebid_config
(
    site_id integer not null,
    timeout integer not null default 1000,
    min_refresh_cpm real not null default 0.05,
    page_active integer not null default 30000,
    unit_visible integer not null default 5000,
    refresh_limit integer not null default 20,
    constraint prebid_config_pkey primary key (site_id)
);


-- key-value targeting (existing keys)
drop table if exists ads.targeting_key;
create table ads.targeting_key
(
    id bigint not null,
    name varchar(255) not null,
    dfp_account_id bigint not null,
    constraint targeting_key_pkey primary key (id)
);


-- key-value targeting (defined values)
drop table if exists ads.targeting_value;
create table ads.targeting_value
(
    id bigint not null,
    name varchar(255) not null,
    key_id bigint not null,
    constraint targeting_key_pkey primary key (id)
);
	
	
-- publishers
drop table if exists ads.users;
create table ads.users
(
    id integer not null auto_increment,
    name varchar(255) not null,
    email varchar(255) not null,
    date_created timestamp default current_timestamp not null,
    date_updated timestamp default current_timestamp not null,
    password varchar(255) not null,
    is_active boolean not null default false,
    constraint user_pkey primary key (id)
);


############### foreign keys ###############
alter table ads.ad_unit 
	add constraint ad_unit_dfp_account_id_fk 
		foreign key (dfp_account_id) references ads.dfp_account (id),
	add constraint ad_unit_site_id_fk 
		foreign key (site_id) references ads.site (id);

alter table ads.ad_unit_prebid_config 
	add constraint ad_unit_prebid_config_ad_unit_id_fk 
		foreign key (ad_unit_id) references ads.ad_unit (id),
	add constraint ad_unit_prebid_config_size_id_fk 
		foreign key (size_id) references ads.size (id),		
	add constraint ad_unit_prebid_config_bidder_id_fk 
		foreign key (bidder_id) references ads.bidder (id);

alter table ads.ad_unit_size 
	add constraint ad_unit_size_ad_unit_id_fk 
		foreign key (ad_unit_id) references ads.ad_unit (id),
	add constraint ad_unit_size_size_id_fk 
		foreign key (size_id) references ads.size (id);

alter table ads.advertiser 
	add constraint advertiser_dfp_account_id_fk 
		foreign key (dfp_account_id) references ads.dfp_account (id);

alter table ads.creative 
	add constraint creative_advertiser_id_fk 
		foreign key (advertiser_id) references ads.advertiser (id),
	add constraint creative_size_id_fk 
		foreign key (size_id) references ads.size (id);

alter table ads.dfp_account 
	add constraint dfp_account_user_id_fk 
		foreign key (user_id) references ads.users (id);

alter table ads.line_item 
	add constraint line_item_order_id_fk 
		foreign key (order_id) references ads.orders (id);

alter table ads.line_item_ad_unit_targeting 
	add constraint line_item_ad_unit_targeting_fk 
		foreign key (ad_unit_id) references ads.ad_unit (id),
	add constraint line_item_ad_unit_targeting_line_item_id_fk 
		foreign key (line_item_id) references ads.line_item (id);
	
alter table ads.line_item_creative 
	add constraint line_item_creative_creative_id_fk 
		foreign key (creative_id) references ads.creative (id),
	add constraint line_item_creative_line_item_id_fk 
		foreign key (line_item_id) references ads.line_item (id);

alter table ads.line_item_targeting 
	add constraint line_item_targeting_targeting_value_id_fk 
		foreign key (targeting_value_id) references ads.targeting_value (id),
	add constraint line_item_targeting_line_item_id_fk 
		foreign key (line_item_id) references ads.line_item (id);	

alter table ads.orders 
	add constraint orders_advertiser_id_fk
		foreign key (advertiser_id) references ads.advertiser (id);

alter table ads.targeting_key 
	add constraint targeting_key_dfp_account_id_fk
		foreign key (dfp_account_id) references ads.dfp_account (id);	
	
alter table ads.targeting_value 
	add constraint targeting_value_fk
		foreign key (key_id) references ads.targeting_key (id);

alter table ads.site 
	add constraint site_user_id_fk
		foreign key (user_id) references ads.users (id);	

alter table ads.site_prebid_config 
	add constraint site_prebid_config_site_id_fk 
		foreign key (site_id) references ads.site (id);	

	
############### indexes ###############
-- к базе данных не нужен ежедневный доступ запросами, но процесс создания объектов очень длинный и тяжелый, все сопоставления айдишек желательно ускорить
-- переиндексация нужна только при добавлении нового клиента и создания для него объектов в dfp
use ads;

create index ad_unit_name_uq on ad_unit(name);

create index ad_unit_code_idx on ad_unit(name);

create index ad_unit_prebid_config_ad_unit_id_idx on ad_unit_prebid_config(ad_unit_id);

create index ad_unit_size_ad_unit_id_idx on ad_unit_size(ad_unit_id);

create index line_item_name_idx on line_item(name);

create index line_item_name_order_id_idx on line_item(order_id);

create index line_item_targeting_line_item_id_idx on line_item_targeting(line_item_id);

create index orders_name_idx on orders(name);

create index orders_advertiser_id_idx on orders(advertiser_id);

create index site_name_idx on site(name);

create index size_name_idx on size(name);

create index targeting_key_dfp_account_id_idx on targeting_key(dfp_account_id);

create index targeting_value_key_id_idx on targeting_value(key_id);