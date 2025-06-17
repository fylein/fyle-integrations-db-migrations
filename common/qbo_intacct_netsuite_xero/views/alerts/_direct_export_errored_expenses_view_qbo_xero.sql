DROP VIEW IF EXISTS _direct_export_errored_expenses_view;

CREATE VIEW _direct_export_errored_expenses_view AS
WITH prod_workspace_ids AS (
    SELECT id
    FROM prod_workspaces_view
),
errored_expenses_in_complete_state AS (
    SELECT COUNT(*)  AS complete_expenses_error_count
    FROM expenses
    WHERE
        workspace_id IN (SELECT id FROM prod_workspace_ids)
        AND accounting_export_summary->>'state' not in ('COMPLETE', 'DELETED')
        AND id IN (
            SELECT expense_id
            FROM expense_groups_expenses
            WHERE expensegroup_id IN (
                SELECT expense_group_id
                FROM task_logs
                WHERE status = 'COMPLETE'
                AND workspace_id IN (SELECT id FROM prod_workspace_ids)
            )
        )
),
errored_expenses_in_error_state AS (
    SELECT COUNT(*) AS error_expenses_error_count
    FROM expenses
    WHERE
        workspace_id IN (SELECT id FROM prod_workspace_ids)
        AND accounting_export_summary->>'state' not in ('ERROR', 'DELETED')
        AND id IN (
            SELECT expense_id
            FROM expense_groups_expenses
            WHERE expensegroup_id IN (
                SELECT expense_group_id
                FROM task_logs
                WHERE status IN ('FAILED', 'FATAL')
                AND workspace_id IN (SELECT id FROM prod_workspace_ids)
            )
        )
),
errored_expenses_in_inprogress_state AS (
    SELECT COUNT(*) AS in_progress_expenses_error_count
    FROM expenses
    WHERE
        workspace_id IN (SELECT id FROM prod_workspace_ids)
        AND accounting_export_summary->>'state' not in ('IN_PROGRESS', 'DELETED')
        AND id IN (
            SELECT expense_id
            FROM expense_groups_expenses
            WHERE expensegroup_id IN (
                SELECT expense_group_id
                FROM task_logs
                WHERE status = 'IN_PROGRESS'
                AND workspace_id IN (SELECT id FROM prod_workspace_ids)
            )
        )
),
not_synced_to_platform AS (
    SELECT COUNT(*) AS not_synced_expenses_count
    FROM expenses e
    INNER JOIN workspace_general_settings wgs on e.workspace_id = wgs.workspace_id
    WHERE
        e.workspace_id IN (SELECT id FROM prod_workspace_ids)
        AND e.accounting_export_summary->>'synced' = 'false'
        AND wgs.skip_accounting_export_summary_post = 'false'
)
SELECT 
    complete_expenses_error_count,
    error_expenses_error_count,
    in_progress_expenses_error_count,
    not_synced_expenses_count
FROM 
    errored_expenses_in_complete_state,
    errored_expenses_in_error_state,
    errored_expenses_in_inprogress_state,
    not_synced_to_platform;
