drop view if exists prod_active_workspaces_view;

create or replace view prod_active_workspaces_view as
SELECT w.id,
    w.name,
    w.org_id,
    w.reimbursable_last_synced_at,
    w.credit_card_last_synced_at,
    w.source_synced_at,
    w.destination_synced_at,
    w.onboarding_state,
    w.ms_business_central_accounts_last_synced_at,
    w.business_central_company_name,
    w.business_central_company_id,
    w.created_at,
    w.updated_at,
    array_agg(u.email) AS user_emails
   FROM workspaces w
     JOIN workspaces_user wu ON wu.workspace_id = w.id
     JOIN users u ON u.id = wu.user_id
  WHERE u.email::text !~~* '%fyle%'::text AND (w.id IN ( SELECT DISTINCT accounting_exports.workspace_id
           FROM accounting_exports
          WHERE accounting_exports.status::text = 'COMPLETE'::text AND accounting_exports.type::text <> 'FETCHING_CREDIT_CARD_EXPENSES'::text AND accounting_exports.type::text <> 'FETCHING_REIMBURSABLE_EXPENSES'::text AND accounting_exports.type::text <> ''::text AND accounting_exports.updated_at > (now() - '3 mons'::interval)))
  GROUP BY w.id;
