-------- All APIs except QBD
DROP VIEW IF EXISTS _import_logs_fatal_failed_in_progress_tasks_view;

CREATE VIEW _import_logs_fatal_failed_in_progress_tasks_view AS
SELECT
    COUNT(*) AS log_count, 
    status,
    current_database() AS database
FROM
    import_logs
WHERE
    status IN ('IN_PROGRESS', 'FATAL', 'FAILED')
    AND workspace_id IN (
        SELECT id
        FROM prod_workspaces_view
    )
    AND error_log::text NOT ILIKE '%Token%'
    AND error_log::text NOT ILIKE '%tenant%'
    AND  updated_at < NOW() - INTERVAL '45 min'
GROUP BY 
    status;
