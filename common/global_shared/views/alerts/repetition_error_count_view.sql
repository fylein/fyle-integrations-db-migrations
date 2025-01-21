-------- All APIs except QBD
--- No alerts, once we handle the retry limits then can remove this
DROP VIEW IF EXISTS repetition_error_count_view;

CREATE OR REPLACE VIEW repetition_error_count_view AS
SELECT
    COUNT(*),
    current_database() AS database
FROM
    errors
WHERE
    repetition_count > 20
    AND workspace_id IN (
        SELECT
            id
        FROM
            prod_workspaces_view
    )
    AND is_resolved = 'f'
    AND created_at < NOW() - INTERVAL '2 months';
