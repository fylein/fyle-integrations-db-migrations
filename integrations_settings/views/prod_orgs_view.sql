drop view if exists prod_orgs_view;

create or replace view prod_orgs_view as

select 
    o.*,
    array_agg(u.email) as user_emails
from orgs o
join orgs_user ou on ou.org_id = o.id
join users u on u.id = ou.user_id
where u.email not ilike '%fyle%'
group by 1
;
