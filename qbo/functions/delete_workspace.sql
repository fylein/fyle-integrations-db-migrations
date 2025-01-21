CREATE OR REPLACE FUNCTION delete_workspace(_workspace_id integer)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rcount integer;
    _org_id varchar(255);
BEGIN
    -- Log workspace deletion process
    RAISE NOTICE 'Deleting data from workspace %', _workspace_id;

    -- Delete from task_logs
    DELETE FROM task_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % task_logs', rcount;

    -- Delete from errors
    DELETE FROM errors WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % errors', rcount;

    -- Delete from last_export_details
    DELETE FROM last_export_details WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % last_export_details', rcount;

    -- Delete from import_logs
    DELETE FROM import_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % import_logs', rcount;

    -- Delete related bill_lineitems
    DELETE FROM bill_lineitems
    WHERE bill_id IN (
        SELECT id FROM bills
        WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bill_lineitems', rcount;

    -- Delete related bills
    DELETE FROM bills
    WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bills', rcount;

    -- Continue for other related tables...

    -- Delete workspace_users
    DELETE FROM workspaces_user WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspaces_user', rcount;

    -- Delete users
    DELETE FROM users
    WHERE id IN (
        SELECT user_id FROM workspaces_user WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % users', rcount;

    -- Capture org_id for external operations
    _org_id := (SELECT fyle_org_id FROM workspaces WHERE id = _workspace_id);

    -- Delete the workspace
    DELETE FROM workspaces WHERE id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspaces', rcount;

    -- External operation reminders
    RAISE NOTICE E'\n\nSwitch to integration_settings DB and run the query to delete the integration:';
    RAISE NOTICE E'\\c integration_settings;\n\nBEGIN;\nSELECT delete_integration(''%s'');\n', _org_id;

    RAISE NOTICE E'\n\nSwitch to prod DB and run the query to update the subscription:';
    RAISE NOTICE E'BEGIN;\nUPDATE platform_schema.admin_subscriptions\nSET is_enabled = false\nWHERE org_id = ''%s'';\n', _org_id;

    RETURN;
END;
$function$;
