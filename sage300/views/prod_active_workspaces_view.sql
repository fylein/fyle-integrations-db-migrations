drop view if exists prod_active_workspaces_view;

create or replace view prod_active_workspaces_view as
SELECT w.*, 
    array_agg(u.email) AS user_emails
   FROM workspaces w
     JOIN workspaces_user wu ON wu.workspace_id = w.id
     JOIN users u ON u.id = wu.user_id
  WHERE u.email !~* 'fyle' AND (w.id IN ( SELECT DISTINCT accounting_exports.workspace_id
           FROM accounting_exports
          WHERE accounting_exports.status = 'COMPLETE' AND accounting_exports.type !~* 'FETCHING_' AND accounting_exports.type::text <> ''::text AND accounting_exports.updated_at > (now() - '3 mons'::interval)))
  GROUP BY w.id;
