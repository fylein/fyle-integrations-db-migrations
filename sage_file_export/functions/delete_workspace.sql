DROP FUNCTION if exists delete_workspace;

CREATE OR REPLACE FUNCTION delete_workspace(IN _workspace_id integer) RETURNS void AS $$
DECLARE
  rcount integer;
  _org_id varchar(255);
BEGIN
  RAISE NOTICE 'Deleting data from workspace % ', _workspace_id;

  DELETE
  FROM accounting_incoming_payload aiul
  WHERE aiul.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % accounting_incoming_payload', rcount;

  DELETE
  FROM failed_events fe
  WHERE fe.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % failed_events', rcount;

  DELETE 
  FROM import_logs il
  WHERE il.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % import_logs', rcount;

  DELETE
  FROM sage_50_payments_journal_line_items pjli
  WHERE pjli.payments_journal_id IN (
      SELECT pj.id FROM sage_50_payments_journals pj WHERE pj.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % sage_50_payments_journal_line_items', rcount;

  DELETE
  FROM sage_50_payments_journals pj
  WHERE pj.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % sage_50_payments_journals', rcount;

  DELETE
  FROM sage_50_general_journal_entry_line_items gjeli
  WHERE gjeli.general_journal_entry_id IN (
      SELECT gje.id FROM sage_50_general_journal_entries gje WHERE gje.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % sage_50_general_journal_entry_line_items', rcount;

  DELETE
  FROM sage_50_general_journal_entries gje
  WHERE gje.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % sage_50_general_journal_entries', rcount;

  DELETE
  FROM sage_50_purchase_receive_inventory_line_items prieli
  WHERE prieli.purchase_receive_inventory_id IN (
      SELECT pri.id FROM sage_50_purchase_receive_inventories pri WHERE pri.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % sage_50_purchase_receive_inventory_line_items', rcount;

  DELETE
  FROM sage_50_purchase_receive_inventories pri
  WHERE pri.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % sage_50_purchase_receive_inventories', rcount;

  DELETE
  FROM expenses e
  WHERE e.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expenses', rcount;

  DELETE
  FROM errors er
  where er.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % errors', rcount;

  DELETE
  FROM export_logs el
  WHERE el.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % export_logs', rcount;

  DELETE
  FROM employee_mappings em
  WHERE em.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % employee_mappings', rcount;

  DELETE
  FROM category_mappings cm
  WHERE cm.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % category_mappings', rcount;

  DELETE
  FROM mappings m
  WHERE m.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % mappings', rcount;

  DELETE
  FROM mapping_settings ms
  WHERE ms.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % mapping_settings', rcount;

  DELETE
  FROM sage_50_advanced_settings sads
  WHERE sads.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % advanced_settings', rcount;

  DELETE
  FROM sage_50_export_settings ses
  WHERE ses.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % export_settings', rcount;

  DELETE
  FROM sage_50_import_settings sis
  WHERE sis.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % import_settings', rcount;

  DELETE
  FROM fyle_credentials fc
  WHERE fc.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % fyle_credentials', rcount;

  DELETE
  from expense_attributes_deletion_cache ead
  WHERE ead.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expense_attributes_deletion_cache', rcount;

  DELETE
  FROM expense_attributes ea
  WHERE ea.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expense_attributes', rcount;

  DELETE
  FROM expense_filters ef
  WHERE ef.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expense_filters', rcount;

  DELETE
  FROM destination_attributes da
  WHERE da.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % destination_attributes', rcount;

  DELETE
  FROM django_q_schedule dqs
  WHERE dqs.args = _workspace_id::varchar(255);
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % django_q_schedule', rcount;

  DELETE
  FROM auth_tokens aut
  WHERE aut.user_id IN (
      SELECT u.id FROM users u WHERE u.id IN (
          SELECT wu.user_id FROM workspaces_user wu WHERE workspace_id = _workspace_id
      )
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % auth_tokens', rcount;

  DELETE
  FROM workspaces_user wu
  WHERE workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % workspaces_user', rcount;

  DELETE
  FROM users u
  WHERE u.id IN (
      SELECT wu.user_id FROM workspaces_user wu WHERE workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % users', rcount;

  _org_id := (SELECT org_id FROM workspaces WHERE id = _workspace_id);

  DELETE
  FROM workspaces w
  WHERE w.id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % workspaces', rcount;

  RAISE NOTICE E'\n\n\n\n\n\n\n\n\nSwitch to integration_settings db and run the below query to delete the integration';
  RAISE NOTICE E'\\c integration_settings; \n\n begin; select delete_integration(''%'');\n\n\n\n\n\n\n\n\n\n\n', _org_id;

  RAISE NOTICE E'\n\n\n\n\n\n\n\n\nSwitch to prod db and run the below query to update the subscription';
  RAISE NOTICE E'begin; update platform_schema.admin_subscriptions set is_enabled = false where org_id = ''%'';\n\n\n\n\n\n\n\n\n\n\n', _org_id;

  RAISE NOTICE E'\n\n\n\n\n\n\n\n\nSwitch to prod db and reset the accounting export summary';

RETURN;
END
$$ LANGUAGE plpgsql;
