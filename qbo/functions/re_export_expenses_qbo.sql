DROP FUNCTION if exists re_export_expenses_qbo;

CREATE OR REPLACE FUNCTION re_export_expenses_qbo(IN _workspace_id integer, _expense_group_ids integer[]) RETURNS void AS $$

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
	FROM credit_card_purchase_lineitems ccpl
	WHERE ccpl.credit_card_purchase_id IN (
		SELECT ccp.id FROM credit_card_purchases ccp WHERE ccp.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % credit_card_purchase_lineitems', rcount;

DELETE
	FROM credit_card_purchases WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % credit_card_purchases', rcount;

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

DELETE
	FROM qbo_expense_lineitems qel
	WHERE qel.qbo_expense_id IN (
		SELECT qe.id FROM qbo_expenses qe WHERE qe.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % qbo_expense_lineitems', rcount;

DELETE
	FROM qbo_expenses WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % qbo_expenses', rcount;

DELETE
	FROM cheque_lineitems cl
	WHERE cl.cheque_id IN (
		SELECT cq.id FROM cheques cq WHERE cq.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % cheque_lineitems', rcount;

DELETE
	FROM cheques WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % cheques', rcount;

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
