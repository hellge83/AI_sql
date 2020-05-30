use ads;

insert into users (name, email, password, is_active) values 
	('user1', 'user1@mail.com', '', True),
	('user2', 'user2@mail.com', '', True);

insert into site (name, url, user_id) values 
	('site1', 'https://site1.com', 1),
	('site2', 'https://site2.com', 2),
	('site3', 'https://site3.com', 2);
	
insert into size (name) values
	('160x600'),
	('300x250'),
	('320x50'),
	('728x90'),
	('970x250');
	
insert into dfp_account (id, user_id, name) values
	(FLOOR(10000 + (RAND() * 1000000)), 1, 'user1'),
	(FLOOR(10000 + (RAND() * 1000000)), 2, 'user2');

insert into 
	targeting_key (id, name, dfp_account_id)
select FLOOR(10000 + (RAND() * 1000000)) id, 'hb_pb' name, dfp_account.id 
from dfp_account;

insert into targeting_value (id, name, key_id)
	select 
	FLOOR(10000 + (RAND() * 1000000))
	, cast(round(RAND() * 10, 2) as char)
	, fst.id 
	from targeting_key as fst, targeting_key as snd, targeting_key as thd;

insert into advertiser (id, name, dfp_account_id) values
	(FLOOR(10000 + (RAND() * 1000000)), 'our_adv', (select id from dfp_account where user_id = 1)),
	(FLOOR(10000 + (RAND() * 1000000)), 'our_adv', (select id from dfp_account where user_id = 2));

insert into bidder (name, code) values
	('152Media', 'oftmedia'),
	('Aardvark', 'aardvark'),
	('Adblade', 'adblade'),
	('AdBund', 'adbund'),
	('AdButler', 'adbutler'),
	('Adform', 'adform'),
	('AdKernel', 'adkernel'),
	('AdMdia', 'admedia'),
	('AdMixer', 'admixer'),
	('AdSupply', 'adsupply');

insert into site_prebid_config (site_id)
	select 
	s.id
	from site s;

drop table if exists tmp;
create table tmp as select *
from(
	select
	FLOOR(10000 + (RAND() * 1000000)) unit_id
	, s.name site_name
	, d.id dfp_id
	, s.id site_id
	from site s
	join dfp_account d on s.user_id = d.user_id) x1
cross join 
	(select s1.name size_name, s1.id size_id from size s1, size s2) x2
order by rand()
limit 12;

insert into ad_unit (id, name, code, dfp_account_id, site_id)
	select 
	tmp.unit_id
	, concat(tmp.site_name, '_', tmp.size_name) name
	, concat(tmp.site_name, '_', tmp.size_name, '_', row_number() over(partition by tmp.site_name, tmp.size_name)) code
	, tmp.dfp_id
	, tmp.site_id 
	from tmp;

insert into ad_unit_size (ad_unit_id, size_id)
	select 
	unit_id, s.id
	from tmp
	join size s on tmp.size_name = s.name;
	
insert into ad_unit_prebid_config (ad_unit_id, size_id, bidder_id, params)
	select 
	ad_unit_id
	, size_id 
	, bidder.id 
	, concat('{"placement_id": "', FLOOR(10000 + (RAND() * 10000000)), '"}')
	from ad_unit_size aus 
	cross join bidder 
	order by rand()
	limit 100;

-- представление тут не нужно. Но по условию задачи в работе их должно быть минимум два. Это первое
drop view if exists tmp_ord;
create view tmp_ord as
	with tmp2 as (
		select 
		a.name adv
		, s.name site
		, s.id site_id
		, tmp.size_name 
		, a.id 
		, tmp.size_id 
		from site s 
		join dfp_account d on s.user_id = d.user_id 
		join advertiser a on d.id = a.dfp_account_id
		join tmp on s.id = tmp.site_id 
	)
	select
		FLOOR(10000 + (RAND() * 1000000)) id
		, concat(adv, '_', site, '_', size_name) name
		, id advertiser
		, size_id 
		, site_id 
	from tmp2;

insert into orders (id, name, advertiser_id)
	select id, name, advertiser from tmp_ord;

insert into line_item 
with tmp3 as (
	select 
	o.name ord_name
, a.dfp_account_id 
, tk.id tk_id
	, tv.name price
	, o.id ord_id
	from orders o
	join advertiser a on o.advertiser_id = a.id 
	join targeting_key tk on a.dfp_account_id = tk.dfp_account_id 
	join targeting_value tv on tv.key_id = tk.id)
select
	FLOOR(10000 + (RAND() * 1000000))
	, concat(tmp3.ord_name, '_', tmp3.price) name 
	, tmp3.ord_id
	from tmp3;

insert into line_item_ad_unit_targeting (line_item_id, ad_unit_id )
with tmp4 as(
	select 
	au.id unit_id
	, au.dfp_account_id
	, au.site_id
	, aus.size_id
	, a.id adv_id
	, tor.id ord_id
	from ad_unit au 
	join ad_unit_size aus on aus.ad_unit_id = au.id 
	join advertiser a on a.dfp_account_id = au.dfp_account_id 
	join tmp_ord tor on (a.id = tor.advertiser and aus.size_id = tor.size_id and au.site_id = tor.site_id)
	)
select 
li.id 
-- , ord_id 
-- , size_id 
, unit_id
from tmp4
join line_item li on li.order_id = tmp4.ord_id;

insert into line_item_targeting (line_item_id, targeting_value_id )
	select 
	li.id li_id
	-- , substring_index(li.name, '_', -1) val
	-- , tv.name
	, tv.id val_id
	from line_item li 
	join targeting_value tv on substring_index(li.name, '_', -1) = tv.name; 

insert into creative (id, name, size_id, advertiser_id)
with tmp5 as (
	select 
	aus.size_id size_id
	, s.name size_name
	, a.id adv_id
	, a.name adv_name
	from ad_unit au
	join ad_unit_size aus on au.id = aus.ad_unit_id 
	join advertiser a on a.dfp_account_id = au.dfp_account_id
	join size s on s.id = aus.size_id 
	group by 1, 2, 3, 4)
select 
	FLOOR(10000 + (RAND() * 1000000)) id
	, concat(fst.adv_name, '_', fst.size_name) name
	, fst.size_id
	, fst.adv_id
	from tmp5 as fst, tmp5 as snd;

insert into line_item_creative (line_item_id, creative_id)
	select 
	li.id li_id
	-- , a.id adv_id
	-- , s.id size_id
	, c.id creative_id
	-- , substring_index(trim(leading concat(substring_index(li.name, '_', 3), '_') from li.name), '_', 1) size_name
	from line_item li
	join line_item_targeting lit on li.id = lit.line_item_id 
	join targeting_value tv on tv.id = lit.targeting_value_id 
	join targeting_key tk on tk.id = tv.key_id 
	join advertiser a on a.dfp_account_id = tk.dfp_account_id
	left join `size` s on substring_index(trim(leading concat(substring_index(li.name, '_', 3), '_') from li.name), '_', 1) = s.name 
	join creative c on c.advertiser_id = a.id and c.size_id = s.id;

-- это второе ненужное представление. Временной таблицы было бы вполне достаточно
drop view if exists tmp_site_params;
create view tmp_site_params as
with config as (select 
	s.name site
	, s.id site_id
	, da.id dfp_id
	, spc.timeout 
	, spc.min_refresh_cpm 
	, au.code unit_code
	, sz.name sizes
	, spc.page_active 
	, spc.unit_visible 
	, spc.refresh_limit 
	, b.code bidder
	, aupc.params
	from site s
	join dfp_account da on s.user_id = da.user_id 
	join site_prebid_config spc on spc.site_id = s.id 
	join ad_unit au on s.id = au.site_id 
	join ad_unit_size aus on au.id = aus.ad_unit_id 
	join size sz on aus.size_id = sz.id 
	join ad_unit_prebid_config aupc on aupc.ad_unit_id = au.id 
	join bidder b on aupc.bidder_id = b.id
	),
bids as (select 
	site
	, site_id
	, unit_code
	, dfp_id, timeout, min_refresh_cpm
	, sizes
	, page_active
	, unit_visible
	, refresh_limit
	, json_arrayagg(json_object(
			'bidder', bidder
			, 'params', params
		)) bids
	from config
	group by 1, 2)
select
site_id
, json_object('siteId', site
	, 'dfpId', dfp_id
	, 'timeout', timeout
	, 'minRefreshCpm', min_refresh_cpm
	, 'adUnits', json_arrayagg(json_object(
		'code', unit_code
		, 'sizes', sizes
		, 'refresh', json_object(
			'after', json_object(
				'pageActive', page_active
				, 'unitVisible', unit_visible)
			, 'limit', refresh_limit)
		, 'bids', bids))
	) params
from bids
group by 1;

update site set prebid = (select params from tmp_site_params where tmp_site_params.site_id = site.id);

drop table if exists tmp;
-- drop view if exists tmp_ord;
-- drop view if exists tmp_site_params;


