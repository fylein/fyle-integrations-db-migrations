DROP VIEW if exists export_log_fatal_in_progress_export_processed_tasks_view;

CREATE OR REPLACE VIEW export_log_fatal_in_progress_export_processed_tasks_view AS
WITH export_log_fatal_in_progress_export_processed_tasks AS (
    SELECT status as status,
    COUNT(*) AS count
    FROM export_logs
    WHERE
        workspace_id IN (SELECT id FROM prod_workspaces_view)
        AND status IN ('FATAL', 'IN_PROGRESS', 'EXPORT_PROCESSED')
        AND updated_at BETWEEN NOW() - INTERVAL '24 hours' AND NOW() - INTERVAL '45 mins'
    GROUP BY status
)
SELECT * FROM export_log_fatal_in_progress_export_processed_tasks;