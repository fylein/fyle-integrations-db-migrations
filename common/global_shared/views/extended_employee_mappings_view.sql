create or replace view extended_employee_mappings_view as
select  
    ea.id as expense_attribute_id,
    ea.attribute_type as expense_attribute_attribute_type,
    ea.display_name as expense_attribute_display_name,
    ea.value as expense_attribute_value,
    ea.auto_mapped as expense_attribute_auto_mapped,
    ea.auto_created as expense_attribute_auto_created,
    ea.created_at as expense_attribute_created_at,
    ea.updated_at as expense_attribute_updated_at,
    ea.source_id as expense_attribute_source_id,
    ea.detail as expense_attribute_detail,
    ea.active as expense_attribute_active,
    
    da.id as destination_attribute_id,
    da.attribute_type as destination_attribute_attribute_type,
    da.display_name as destination_attribute_display_name,
    da.value as destination_attribute_value,
    da.destination_id as destination_attribute_destination_id,
    da.auto_created as destination_attribute_auto_created,
    da.detail as destination_attribute_detail,
    da.active as destination_attribute_active,
    -- da.code as destination_attribute_code,
    da.created_at as destination_attribute_created_at,
    da.updated_at as destination_attribute_updated_at,
    em.workspace_id as workspace_id

    from employee_mappings em
    join expense_attributes ea on ea.id = em.source_employee_id
    join destination_attributes da on da.id = em.destination_employee_id
    join destination_attributes da2 on da2.id = em.destination_vendor_id
    join destination_attributes da3 on da3.id = em.destination_card_account_id
;
