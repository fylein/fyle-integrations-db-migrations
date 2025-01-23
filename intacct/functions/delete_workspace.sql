CREATE OR REPLACE FUNCTION public.delete_workspace(_workspace_id integer)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rcount integer;
    _org_id varchar(255);
BEGIN
    RAISE NOTICE 'Deleting data from workspace %', _workspace_id;

    -- Delete from dependent_field_settings
    DELETE FROM dependent_field_settings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % dependent_field_settings', rcount;

    -- Delete from cost_types
    DELETE FROM cost_types WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % cost_types', rcount;

    -- Delete from location_entity_mappings
    DELETE FROM location_entity_mappings WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % location_entity_mappings', rcount;

    -- Delete from expense_fields
    DELETE FROM expense_fields WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_fields', rcount;

    -- Delete from errors
    DELETE FROM errors WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % errors', rcount;

    -- Delete from import_logs
    DELETE FROM import_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % import_logs', rcount;

    -- Delete from task_logs
    DELETE FROM task_logs WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % task_logs', rcount;

    -- Delete from bill_lineitems
    DELETE FROM bill_lineitems
    WHERE bill_id IN (
        SELECT b.id FROM bills b
        WHERE b.expense_group_id IN (
            SELECT eg.id FROM expense_groups eg
            WHERE eg.workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bill_lineitems', rcount;

    -- Delete from bills
    DELETE FROM bills
    WHERE expense_group_id IN (
        SELECT eg.id FROM expense_groups eg
        WHERE eg.workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bills', rcount;

    -- Delete from charge_card_transaction_lineitems
    DELETE FROM charge_card_transaction_lineitems
    WHERE charge_card_transaction_id IN (
        SELECT cct.id FROM charge_card_transactions cct
        WHERE cct.expense_group_id IN (
            SELECT eg.id FROM expense_groups eg
            WHERE eg.workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % charge_card_transaction_lineitems', rcount;

    -- Delete from charge_card_transactions
    DELETE FROM charge_card_transactions
    WHERE expense_group_id IN (
        SELECT eg.id FROM expense_groups eg
        WHERE eg.workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % charge_card_transactions', rcount;

    -- Delete from journal_entry_lineitems
    DELETE FROM journal_entry_lineitems
    WHERE journal_entry_id IN (
        SELECT je.id FROM journal_entries je
        WHERE je.expense_group_id IN (
            SELECT eg.id FROM expense_groups eg
            WHERE eg.workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % journal_entry_lineitems', rcount;

    -- Delete from journal_entries
    DELETE FROM journal_entries
    WHERE expense_group_id IN (
        SELECT eg.id FROM expense_groups eg
        WHERE eg.workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % journal_entries', rcount;

    -- Delete from expense_report_lineitems
    DELETE FROM expense_report_lineitems
    WHERE expense_report_id IN (
        SELECT er.id FROM expense_reports er
        WHERE er.expense_group_id IN (
            SELECT eg.id FROM expense_groups eg
            WHERE eg.workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_report_lineitems', rcount;

    -- Delete from expense_reports
    DELETE FROM expense_reports
    WHERE expense_group_id IN (
        SELECT eg.id FROM expense_groups eg
        WHERE eg.workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_reports', rcount;

    -- Delete from ap_payment_lineitems
    DELETE FROM ap_payment_lineitems
    WHERE ap_payment_id IN (
        SELECT ap.id FROM ap_payments ap
        WHERE ap.expense_group_id IN (
            SELECT eg.id FROM expense_groups eg
            WHERE eg.workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % ap_payment_lineitems', rcount;

    -- Delete from ap_payments
    DELETE FROM ap_payments
    WHERE expense_group_id IN (
        SELECT eg.id FROM expense_groups eg
        WHERE eg.workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % ap_payments', rcount;

    -- Delete from sage_intacct_reimbursement_lineitems
    DELETE FROM sage_intacct_reimbursement_lineitems
    WHERE sage_intacct_reimbursement_id IN (
        SELECT sir.id FROM sage_intacct_reimbursements sir
        WHERE sir.expense_group_id IN (
            SELECT eg.id FROM expense_groups eg
            WHERE eg.workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % sage_intacct_reimbursement_lineitems', rcount;

    -- Delete from sage_intacct_reimbursements
    DELETE FROM sage_intacct_reimbursements
    WHERE expense_group_id IN (
        SELECT eg.id FROM expense_groups eg
        WHERE eg.workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % sage_intacct_reimbursements', rcount;

    -- Delete from reimbursements
    DELETE FROM reimbursements
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % reimbursements', rcount;

    -- Delete from expenses
    DELETE FROM expenses
    WHERE id IN (
        SELECT expense_id FROM expense_groups_expenses ege
        WHERE ege.expensegroup_id IN (
            SELECT eg.id FROM expense_groups eg
            WHERE eg.workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expenses', rcount;

    -- Delete skipped expenses
    DELETE FROM expenses
    WHERE is_skipped = true
      AND org_id IN (
          SELECT fyle_org_id FROM workspaces WHERE id = _workspace_id
      );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % skipped expenses', rcount;

    -- Delete from expense_groups_expenses
    DELETE FROM expense_groups_expenses
    WHERE expensegroup_id IN (
        SELECT eg.id FROM expense_groups eg
        WHERE eg.workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_groups_expenses', rcount;

    -- Delete from expense_groups
    DELETE FROM expense_groups
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_groups', rcount;

    -- Delete from mappings
    DELETE FROM mappings
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % mappings', rcount;

    -- Delete from employee_mappings
    DELETE FROM employee_mappings
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % employee_mappings', rcount;

    -- Delete from category_mappings
    DELETE FROM category_mappings
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % category_mappings', rcount;

    -- Delete from mapping_settings
    DELETE FROM mapping_settings
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % mapping_settings', rcount;

    -- Delete from general_mappings
    DELETE FROM general_mappings
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % general_mappings', rcount;

    -- Delete from configurations
    DELETE FROM configurations
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % configurations', rcount;

    -- Delete from fyle_credentials
    DELETE FROM fyle_credentials
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % fyle_credentials', rcount;

    -- Delete from sage_intacct_credentials
    DELETE FROM sage_intacct_credentials
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % sage_intacct_credentials', rcount;

    -- Delete from expense_attributes_deletion_cache
    DELETE FROM expense_attributes_deletion_cache
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_attributes_deletion_cache', rcount;

    -- Delete from expense_attributes
    DELETE FROM expense_attributes
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_attributes', rcount;

    -- Delete from expense_filters
    DELETE FROM expense_filters
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expense_filters', rcount;

    -- Delete from destination_attributes
    DELETE FROM destination_attributes
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % destination_attributes', rcount;

    -- Delete from workspace_schedules
    DELETE FROM workspace_schedules
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspace_schedules', rcount;

    -- Delete from last_export_details
    DELETE FROM last_export_details
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % last_export_details', rcount;

    -- Delete from django_q_schedule
    DELETE FROM django_q_schedule
    WHERE args = _workspace_id::varchar(255);
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % django_q_schedule', rcount;

    -- Delete from auth_tokens
    DELETE FROM auth_tokens
    WHERE user_id IN (
        SELECT u.id FROM users u
        WHERE u.id IN (
            SELECT wu.user_id FROM workspaces_user wu
            WHERE workspace_id = _workspace_id
        )
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % auth_tokens', rcount;

    -- Delete from workspaces_user
    DELETE FROM workspaces_user
    WHERE workspace_id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspaces_user', rcount;

    -- Delete from users
    DELETE FROM users
    WHERE id IN (
        SELECT wu.user_id FROM workspaces_user wu
        WHERE workspace_id = _workspace_id
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % users', rcount;

    -- Retrieve org_id for external operations
    _org_id := (SELECT fyle_org_id FROM workspaces WHERE id = _workspace_id);

    -- Delete from workspaces
    DELETE FROM workspaces
    WHERE id = _workspace_id;
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % workspaces', rcount;

    -- Reminders for external system operations
    RAISE NOTICE E'
    Switch to integration_settings DB and run the below query to delete the integration:
    ';
    RAISE NOTICE E'\\c integration_settings;\nBEGIN;\nSELECT delete_integration(''%s'');\n\n\n\n\n\n\n\n\n\n\n', _org_id;

    RAISE NOTICE E'
    Switch to prod DB and run the below query to update the subscription:
    ';
    RAISE NOTICE E'BEGIN;\nUPDATE platform_schema.admin_subscriptions SET is_enabled = false WHERE org_id = ''%s'';\n\n\n\n\n\n\n\n\n\n\n', _org_id;

    RAISE NOTICE E'
    Switch to prod DB and run the below queries to delete dependent fields:
    ';
    RAISE NOTICE E'ROLLBACK;\nBEGIN;\nDELETE FROM platform_schema.dependent_expense_field_mappings WHERE expense_field_id IN (
        SELECT id FROM platform_schema.expense_fields WHERE org_id = ''%s'' AND type = ''DEPENDENT_SELECT''
    );\nDELETE FROM platform_schema.expense_fields WHERE org_id = ''%s'' AND type = ''DEPENDENT_SELECT'';\n\n\n\n\n\n\n\n\n\n\n', _org_id, _org_id;

    RETURN;
END;
$function$;
