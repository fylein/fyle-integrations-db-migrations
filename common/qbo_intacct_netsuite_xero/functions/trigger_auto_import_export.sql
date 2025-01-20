DROP FUNCTION if exists trigger_auto_import_export;

-- Non QBD
CREATE OR REPLACE FUNCTION trigger_auto_import_export(IN _workspace_id varchar(255)) RETURNS void AS $$
DECLARE
    rcount integer;
BEGIN
    UPDATE django_q_schedule 
    SET next_run = now() + INTERVAL '35 sec' 
    WHERE args = _workspace_id and func = 'apps.workspaces.tasks.run_sync_schedule';
    
    GET DIAGNOSTICS rcount = ROW_COUNT;

    IF rcount > 0 THEN
        RAISE NOTICE 'Updated % schedule', rcount;
    ELSE
        RAISE NOTICE 'Schedule not updated since it doesnt exist';
    END IF;

    update errors set updated_at = now() - interval '25 hours' where is_resolved = 'f' and workspace_id = NULLIF(_workspace_id, '')::int and repetition_count > 100;

RETURN;
END
$$ LANGUAGE plpgsql;
