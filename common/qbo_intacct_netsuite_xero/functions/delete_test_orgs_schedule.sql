DROP FUNCTION if exists delete_test_orgs_schedule;

CREATE OR REPLACE FUNCTION delete_test_orgs_schedule()
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rcount integer;
BEGIN
    
    DELETE FROM workspace_schedules
    WHERE workspace_id NOT IN (
        SELECT id FROM prod_workspaces_view
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspace_schedules', rcount;

    DELETE FROM django_q_schedule
    WHERE args NOT IN (
        SELECT id::text FROM prod_workspaces_view
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % django_q_schedule', rcount;
END;
$function$;
