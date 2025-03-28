DROP FUNCTION if exists re_export_expenses_netsuite;

CREATE OR REPLACE FUNCTION re_export_expenses_netsuite(IN _workspace_id integer, _expense_group_ids integer[]) RETURNS void AS $$

DECLARE
  	rcount integer;
	temp_expenses integer[];
	local_expense_group_ids integer[];
BEGIN
  RAISE NOTICE 'Starting to delete exported entries from workspace % ', _workspace_id; 

local_expense_group_ids := _expense_group_ids;


SELECT array_agg(expense_id) into temp_expenses from expense_groups_expenses where expensegroup_id in (SELECT unnest(local_expense_group_ids));

DELETE
	FROM task_logs WHERE workspace_id = _workspace_id AND status = 'COMPLETE' and expense_group_id in (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % task_logs', rcount;

DELETE
	FROM errors
	where expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % errors', rcount;

DELETE
	FROM bill_lineitems bl
	WHERE bl.bill_id IN (
		SELECT b.id FROM bills b WHERE b.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % bill_lineitems', rcount;

DELETE
	FROM bills WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % bills', rcount;

DELETE
	FROM credit_card_charge_lineitems ccl
	WHERE ccl.credit_card_charge_id IN (
		SELECT ccc.id FROM credit_card_charges ccc WHERE ccc.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % credit_card_charge_lineitems', rcount;

DELETE
	FROM credit_card_charges WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % credit_card_charges', rcount;

DELETE
	FROM expense_report_lineitems erl
	WHERE erl.expense_report_id IN (
		SELECT er.id FROM expense_reports er WHERE er.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % expense_report_lineitems', rcount;

DELETE
	FROM expense_reports WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % expense_reports', rcount;

DELETE
	FROM journal_entry_lineitems jel
	WHERE jel.journal_entry_id IN (
		SELECT je.id FROM journal_entries je WHERE je.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % journal_entry_lineitems', rcount;

DELETE
	FROM journal_entries WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % journal_entries', rcount;

UPDATE 
	expense_groups set exported_at = null, response_logs = null
	WHERE id in (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Updating % expense_groups and resetting exported_at, response_logs', rcount;

UPDATE django_q_schedule 
    SET next_run = now() + INTERVAL '35 sec' 
    WHERE args = _workspace_id::text and func = 'apps.workspaces.tasks.run_sync_schedule';
    
    GET DIAGNOSTICS rcount = ROW_COUNT;

    IF rcount > 0 THEN
        RAISE NOTICE 'Updated % schedule', rcount;
    ELSE
        RAISE NOTICE 'Schedule not updated since it doesnt exist';
    END IF;

RETURN;
END
$$ LANGUAGE plpgsql;
