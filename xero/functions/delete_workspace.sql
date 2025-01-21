CREATE OR REPLACE FUNCTION public.delete_workspace(_workspace_id integer)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rcount integer;
    _org_id varchar(255);
BEGIN
    RAISE NOTICE 'Deleting data from workspace %', _workspace_id;

    -- Delete from related tables
    DELETE FROM import_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % import_logs', rcount;

    DELETE FROM task_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % task_logs', rcount;

    DELETE FROM errors WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % errors', rcount;

    DELETE FROM last_export_details WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % last_export_details', rcount;

    DELETE FROM bill_lineitems
    WHERE bill_id IN (
        SELECT id FROM bills
        WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bill_lineitems', rcount;

    DELETE FROM bills
    WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bills', rcount;

    DELETE FROM bank_transaction_lineitems
    WHERE bank_transaction_id IN (
        SELECT id FROM bank_transactions
        WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bank_transaction_lineitems', rcount;

    DELETE FROM bank_transactions
    WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bank_transactions', rcount;

    DELETE FROM payments WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % payments', rcount;

    DELETE FROM reimbursements WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % reimbursements', rcount;

    DELETE FROM expenses
    WHERE id IN (
        SELECT expense_id FROM expense_groups_expenses
        WHERE expensegroup_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expenses', rcount;

    DELETE FROM expense_groups_expenses
    WHERE expensegroup_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_groups_expenses', rcount;

    DELETE FROM expense_groups WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_groups', rcount;

    DELETE FROM tenant_mappings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % tenant_mappings', rcount;

    DELETE FROM mappings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % mappings', rcount;

    DELETE FROM mapping_settings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % mapping_settings', rcount;

    DELETE FROM general_mappings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % general_mappings', rcount;

    DELETE FROM workspace_general_settings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspace_general_settings', rcount;

    DELETE FROM expense_group_settings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_group_settings', rcount;

    DELETE FROM fyle_credentials WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % fyle_credentials', rcount;

    DELETE FROM xero_credentials WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % xero_credentials', rcount;

    DELETE FROM expense_attributes_deletion_cache WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_attributes_deletion_cache', rcount;

    DELETE FROM expense_attributes WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_attributes', rcount;

    DELETE FROM destination_attributes WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % destination_attributes', rcount;

    DELETE FROM expense_fields WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_fields', rcount;

    DELETE FROM workspace_schedules WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspace_schedules', rcount;

    DELETE FROM django_q_schedule WHERE args = _workspace_id::varchar(255);
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % django_q_schedule', rcount;

    DELETE FROM auth_tokens
    WHERE user_id IN (
        SELECT id FROM users WHERE id IN (
            SELECT user_id FROM workspaces_user WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % auth_tokens', rcount;

    DELETE FROM workspaces_user WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspaces_user', rcount;

    DELETE FROM users
    WHERE id IN (
        SELECT user_id FROM workspaces_user WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % users', rcount;

    _org_id := (SELECT fyle_org_id FROM workspaces WHERE id = _workspace_id);

    DELETE FROM workspaces WHERE id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspaces', rcount;

    -- Reminder to handle external systems
    RAISE NOTICE E'Switch to integration_settings DB and run the query to delete the integration:';
    RAISE NOTICE E'\\c integration_settings;\nBEGIN;\nSELECT delete_integration(''%s'');', _org_id;

    RAISE NOTICE E'Switch to prod DB and update the subscription:';
    RAISE NOTICE E'BEGIN;\nUPDATE platform_schema.admin_subscriptions SET is_enabled = false WHERE org_id = ''%s'';', _org_id;

    RETURN;
END;
$function$;
