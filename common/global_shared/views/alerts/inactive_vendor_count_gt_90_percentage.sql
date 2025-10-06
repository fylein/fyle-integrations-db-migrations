DROP VIEW IF EXISTS inactive_vendor_count_gt_90_percentage;

CREATE VIEW inactive_vendor_count_gt_90_percentage AS
with merchant_stats as (
    select
        workspace_id,
        COUNT(*) AS total_merchants,
        COUNT(*) filter (where active = false) AS inactive_merchants
    from expense_attributes
    where attribute_type = 'MERCHANT'
      and workspace_id in (select id from prod_active_workspaces_view)
    group by 1
)
select
    workspace_id,
    total_merchants,
    inactive_merchants,
    round((inactive_merchants::decimal / total_merchants) * 100, 2) as inactive_percentage
from merchant_stats
where (inactive_merchants::decimal / total_merchants) > 0.90
and total_merchants > 10
order by inactive_percentage desc;