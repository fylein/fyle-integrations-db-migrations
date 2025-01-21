DROP VIEW IF EXISTS direct_export_errored_expenses_view;

CREATE VIEW direct_export_errored_expenses_view AS
WITH prod_workspace_ids AS (
    SELECT id
    FROM prod_workspaces_view
),
-- Task log in complete state but accounting export summary is not in complete state
errored_expenses_in_complete_state AS (
    SELECT COUNT(*) AS complete_expenses_error_count
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
                AND updated_at > (NOW() - INTERVAL '1 day') 
                AND updated_at < (NOW() - INTERVAL '45 mins')
            )
        )
),
-- Task log in error, fatal state but accounting export summary is not in error state
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
                AND updated_at > (NOW() - INTERVAL '1 day') 
                AND updated_at < (NOW() - INTERVAL '45 mins')
            )
        )
),
-- Task log in in progress state but accounting export summary is not in in progress state
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
                WHERE status in ('IN_PROGRESS', 'ENQUEUED')
                AND workspace_id IN (SELECT id FROM prod_workspace_ids)
                AND updated_at > (NOW() - INTERVAL '1 day') 
                AND updated_at < (NOW() - INTERVAL '45 mins')
            )
        )
),
not_synced_to_platform AS (
    SELECT COUNT(*) AS not_synced_expenses_count
    FROM expenses
    WHERE
        workspace_id IN (SELECT id FROM prod_workspace_ids)
        AND accounting_export_summary->>'synced' = 'false'
        AND updated_at > (NOW() - INTERVAL '1 day') 
        AND updated_at < (NOW() - INTERVAL '45 mins')
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
