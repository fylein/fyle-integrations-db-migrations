-------- All APIs except QBD
DROP VIEW IF EXISTS import_logs_fatal_failed_in_progress_tasks_view;

CREATE VIEW import_logs_fatal_failed_in_progress_tasks_view AS
SELECT
    COUNT(*), 
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
    AND updated_at > NOW() - INTERVAL '1 day' and updated_at < NOW() - INTERVAL '45 min'
    AND error_log::text NOT ILIKE '%Token%'
    AND error_log::text NOT ILIKE '%tenant%'
GROUP BY 
    status;
