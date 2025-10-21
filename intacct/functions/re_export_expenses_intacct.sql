DROP FUNCTION if exists re_export_expenses_intacct;

CREATE OR REPLACE FUNCTION re_export_expenses_intacct(IN _workspace_id integer, _expense_group_ids integer[], trigger_export boolean DEFAULT false) RETURNS void AS $$

DECLARE
  	rcount integer;
	temp_expenses integer[];
	local_expense_group_ids integer[];
	_fyle_org_id text;
	expense_ids text;
BEGIN
  RAISE NOTICE 'Starting to delete exported entries from workspace % ', _workspace_id; 

local_expense_group_ids := _expense_group_ids;

_fyle_org_id := (select fyle_org_id from workspaces where id = _workspace_id);

SELECT array_agg(expense_id) into temp_expenses from expense_groups_expenses where expensegroup_id in (SELECT unnest(local_expense_group_ids));

expense_ids := (
	select string_agg(format('%L', expense_id), ', ') 
	from expenses
	where workspace_id = _workspace_id
	and id in (SELECT unnest(temp_expenses))
);

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
	FROM charge_card_transaction_lineitems ccpl
	WHERE ccpl.charge_card_transaction_id IN (
		SELECT ccp.id FROM charge_card_transactions ccp WHERE ccp.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % charge_card_transaction_lineitems', rcount;

DELETE
	FROM charge_card_transactions WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % charge_card_transactions', rcount;

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
	FROM expense_report_lineitems cl
	WHERE cl.expense_report_id IN (
		SELECT cq.id FROM expense_reports cq WHERE cq.expense_group_id IN (
			SELECT unnest(local_expense_group_ids)
		) 
	);
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % expense_report_lineitems', rcount;

DELETE
	FROM expense_reports WHERE expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % expense_reports', rcount;

UPDATE 
	expense_groups set exported_at = null, response_logs = null
	WHERE id in (SELECT unnest(local_expense_group_ids)) and workspace_id = _workspace_id and exported_at is not null;
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Updating % expense_groups and resetting exported_at, response_logs', rcount;

UPDATE
	expenses set accounting_export_summary = '{}'
	where id in (SELECT unnest(temp_expenses));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Updating % expenses and resetting accounting_export_summary', rcount;

RAISE NOTICE E'\n\n\nProd DB Queries to delete accounting export summaries:';
RAISE NOTICE E'rollback; begin; update platform_schema.expenses_wot set accounting_export_summary = \'{}\' where org_id = \'%\' and id in (%); update platform_schema.reports_wot set accounting_export_summary = \'{}\' where org_id = \'%\' and id in (select report->>\'id\' from platform_schema.expenses_rov where org_id = \'%\' and id in (%));', _fyle_org_id, expense_ids, _fyle_org_id, _fyle_org_id, expense_ids;

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
