DROP FUNCTION if exists re_export_expenses_xero;

CREATE OR REPLACE FUNCTION re_export_expenses_xero(IN _workspace_id integer, _expense_group_ids integer[], trigger_export boolean DEFAULT false) RETURNS void AS $$

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
	FROM bank_transaction_lineitems btl
	WHERE btl.bank_transaction_id IN (
		SELECT bt.id FROM bank_transactions bt WHERE bt.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % bank_transaction_lineitems', rcount;

DELETE
	FROM bank_transactions WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % bank_transactions', rcount;

DELETE
	FROM payments WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % payments', rcount;

UPDATE 
	expense_groups set exported_at = null, response_logs = null
	WHERE id in (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Updating % expense_groups and resetting exported_at, response_logs', rcount;

UPDATE
	expenses set accounting_export_summary = '{}'
	where id in (SELECT unnest(temp_expenses));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Updating % expenses and resetting accounting_export_summary', rcount;

IF trigger_export THEN
    UPDATE django_q_schedule 
        SET next_run = now() + INTERVAL '35 sec' 
        WHERE args = _workspace_id::text and func = 'apps.workspaces.tasks.run_sync_schedule';
        
        GET DIAGNOSTICS rcount = ROW_COUNT;

        IF rcount > 0 THEN
            RAISE NOTICE 'Updated % schedule', rcount;
        ELSE
            RAISE NOTICE 'Schedule not updated since it doesnt exist';
        END IF;
END IF;

RETURN;
END
$$ LANGUAGE plpgsql;
