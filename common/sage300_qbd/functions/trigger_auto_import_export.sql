DROP FUNCTION if exists trigger_auto_import_export;

CREATE OR REPLACE FUNCTION trigger_auto_import_export(IN _workspace_id varchar(255)) RETURNS void AS $$
DECLARE
    rcount integer;
BEGIN
    UPDATE django_q_schedule 
    SET next_run = now() + INTERVAL '35 sec' 
    WHERE args = _workspace_id and func = 'apps.workspaces.tasks.run_import_export';
    
    GET DIAGNOSTICS rcount = ROW_COUNT;

    IF rcount > 0 THEN
        RAISE NOTICE 'Updated % schedule', rcount;
    ELSE
        RAISE NOTICE 'Schedule not updated since it doesnt exist';
    END IF;

RETURN;
END
$$ LANGUAGE plpgsql;
