DROP VIEW IF EXISTS receive_queue_in_progress_response_received_tasks_view;

CREATE OR REPLACE VIEW receive_queue_in_progress_response_received_tasks_view AS 
WITH receive_request_queue_in_progress_response_received_tasks AS (
    SELECT status as status,
    COUNT(*) AS count
    FROM qbd_receive_request_queue
    WHERE
        workspace_id IN (SELECT id FROM prod_workspaces_view)
        AND status IN ('IN_PROGRESS', 'RESPONSE_RECEIVED')
        AND updated_at BETWEEN NOW() - INTERVAL '24 hours' AND NOW() - INTERVAL '45 mins'
    GROUP BY status
)
SELECT * FROM receive_request_queue_in_progress_response_received_tasks;
