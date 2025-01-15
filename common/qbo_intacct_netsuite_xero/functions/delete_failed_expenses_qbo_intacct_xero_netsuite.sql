DROP FUNCTION if exists delete_failed_expenses;

CREATE OR REPLACE FUNCTION delete_failed_expenses(IN _workspace_id integer, IN _delete_all boolean DEFAULT false, _expense_group_ids integer[] DEFAULT '{}') RETURNS void AS $$

DECLARE
  	rcount integer;
	temp_expenses integer[];
	local_expense_group_ids integer[];
	total_expense_groups integer;
	failed_expense_groups integer;
BEGIN
  RAISE NOTICE 'Deleting failed expenses from workspace % ', _workspace_id; 

local_expense_group_ids := _expense_group_ids;

IF _delete_all THEN
	-- Update last_export_details when delete_all is true
	select array_agg(expense_group_id) into local_expense_group_ids from task_logs where status='FAILED' and workspace_id=_workspace_id;
	UPDATE last_export_details SET failed_expense_groups_count = 0 WHERE workspace_id = _workspace_id;
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Updated % last_export_details', rcount;
END IF;

SELECT array_agg(expense_id) into temp_expenses from expense_groups_expenses where expensegroup_id in (SELECT unnest(local_expense_group_ids));

DELETE
	FROM task_logs WHERE workspace_id = _workspace_id AND status = 'FAILED' and expense_group_id in (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % task_logs', rcount;

DELETE
	FROM errors
	where expense_group_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % errors', rcount;

DELETE 
	FROM expense_groups_expenses WHERE expensegroup_id IN (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % expense_groups_expenses', rcount;

DELETE 
	FROM expense_groups WHERE id in (SELECT unnest(local_expense_group_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % expense_groups', rcount;

IF NOT _delete_all THEN
    UPDATE last_export_details
        SET total_expense_groups_count = total_expense_groups_count - rcount,
            failed_expense_groups_count = failed_expense_groups_count - rcount,
            updated_at = NOW()
        WHERE workspace_id = _workspace_id;

    total_expense_groups := (SELECT total_expense_groups_count FROM last_export_details WHERE workspace_id = _workspace_id);
    failed_expense_groups := (SELECT failed_expense_groups_count FROM last_export_details WHERE workspace_id = _workspace_id);

    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Updated last_export_details';
    RAISE NOTICE 'New total_expense_groups_count: %', total_expense_groups;
    RAISE NOTICE 'New failed_expense_groups_count: %', failed_expense_groups;
END IF;


DELETE 
	FROM expenses WHERE id in (SELECT unnest(temp_expenses));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % expenses', rcount;

RETURN;
END
$$ LANGUAGE plpgsql;
