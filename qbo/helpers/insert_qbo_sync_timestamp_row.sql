INSERT INTO qbo_sync_timestamps (
    workspace_id,
    account_synced_at,
    item_synced_at,
    vendor_synced_at,
    employee_synced_at,
    department_synced_at,
    tax_code_synced_at,
    class_synced_at,
    customer_synced_at,
    created_at,
    updated_at
)
SELECT 
    w.id as workspace_id,
    NULL as account_synced_at,
    NULL as item_synced_at,
    NULL as vendor_synced_at,
    NULL as employee_synced_at,
    NULL as department_synced_at,
    NULL as tax_code_synced_at,
    NULL as class_synced_at,
    NULL as customer_synced_at,
    NOW() as created_at,
    NOW() as updated_at
FROM workspaces w
LEFT JOIN qbo_sync_timestamps qst ON w.id = qst.workspace_id
WHERE qst.workspace_id IS NULL;
