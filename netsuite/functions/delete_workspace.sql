CREATE OR REPLACE FUNCTION delete_workspace(_workspace_id integer)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rcount integer;
    _org_id varchar(255);
BEGIN
    RAISE NOTICE 'Deleting data from workspace %', _workspace_id;

    -- Delete records from related tables
    DELETE FROM import_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % import_logs', rcount;

    DELETE FROM task_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % task_logs', rcount;

    DELETE FROM bill_lineitems WHERE bill_id IN (
        SELECT id FROM bills WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bill_lineitems', rcount;

    DELETE FROM bills WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bills', rcount;

    DELETE FROM credit_card_charge_lineitems WHERE credit_card_charge_id IN (
        SELECT id FROM credit_card_charges WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % credit_card_charge_lineitems', rcount;

    DELETE FROM credit_card_charges WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % credit_card_charges', rcount;

    DELETE FROM expense_report_lineitems WHERE expense_report_id IN (
        SELECT id FROM expense_reports WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_report_lineitems', rcount;

    DELETE FROM expense_reports WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_reports', rcount;

    DELETE FROM journal_entry_lineitems WHERE journal_entry_id IN (
        SELECT id FROM journal_entries WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % journal_entry_lineitems', rcount;

    DELETE FROM journal_entries WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % journal_entries', rcount;

    DELETE FROM reimbursements WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % reimbursements', rcount;

    DELETE FROM expenses WHERE id IN (
        SELECT expense_id FROM expense_groups_expenses WHERE expensegroup_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expenses', rcount;

    DELETE FROM expense_groups_expenses WHERE expensegroup_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_groups_expenses', rcount;

    DELETE FROM vendor_payment_lineitems WHERE expense_group_id IN (
        SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % vendor_payment_lineitems', rcount;

    DELETE FROM vendor_payments WHERE id IN (
        SELECT vendor_payment_id FROM vendor_payment_lineitems WHERE expense_group_id IN (
            SELECT id FROM expense_groups WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % vendor_payments', rcount;

    DELETE FROM expense_groups WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_groups', rcount;

    DELETE FROM mappings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % mappings', rcount;

    DELETE FROM configurations WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % configurations', rcount;

    DELETE FROM fyle_credentials WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % fyle_credentials', rcount;

    DELETE FROM netsuite_credentials WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % netsuite_credentials', rcount;

    DELETE FROM workspaces WHERE id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspaces', rcount;

    _org_id := (SELECT fyle_org_id FROM workspaces WHERE id = _workspace_id);

    RAISE NOTICE E'Switch to integration_settings DB and delete the integration:';
    RAISE NOTICE E'\\c integration_settings;\nBEGIN;\nSELECT delete_integration(''%s'');', _org_id;

    RAISE NOTICE E'Switch to prod DB and update the subscription:';
    RAISE NOTICE E'BEGIN;\nUPDATE platform_schema.admin_subscriptions\nSET is_enabled = false\nWHERE org_id = ''%s'';', _org_id;

    RETURN;
END;
$function$;
