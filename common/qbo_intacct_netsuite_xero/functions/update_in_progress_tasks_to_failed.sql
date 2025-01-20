DROP FUNCTION if exists update_in_progress_tasks_to_failed;

CREATE OR REPLACE FUNCTION update_in_progress_tasks_to_failed(_expense_group_ids integer[]) RETURNS void AS $$

DECLARE
  rcount integer;

BEGIN
    RAISE NOTICE 'Updating in progress tasks to failed for expense groups % ', _expense_group_ids;

UPDATE
    task_logs SET status = 'FAILED' WHERE status in ('ENQUEUED', 'IN_PROGRESS') and expense_group_id in (SELECT unnest(_expense_group_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Updated % task_logs', rcount;

RETURN;
END
$$ LANGUAGE plpgsql;
