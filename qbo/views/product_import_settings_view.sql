DROP VIEW IF EXISTS product_import_settings_view;
CREATE VIEW product_import_settings_view AS
SELECT 
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    wgs.import_categories,
    wgs.import_items,
    wgs.charts_of_accounts,
    wgs.import_tax_codes,
    wgs.import_vendors_as_merchants,
    wgs.import_code_fields,
    -- General Mappings
    gm.default_tax_code_name,
    gm.default_tax_code_id,
    -- Mapping Settings as Array of JSON Objects
    COALESCE(
        JSON_AGG(
            JSON_BUILD_OBJECT(
                'source_field', ms.source_field,
                'destination_field', ms.destination_field,
                'import_to_fyle', ms.import_to_fyle,
                'is_custom', ms.is_custom,
                'source_placeholder', ms.source_placeholder
            )
        ) FILTER (WHERE ms.workspace_id IS NOT NULL),
        '[]'
    ) AS mapping_settings_array
FROM 
    workspaces w
JOIN 
    workspace_general_settings wgs ON w.id = wgs.workspace_id
JOIN 
    general_mappings gm ON w.id = gm.workspace_id
LEFT JOIN 
    mapping_settings ms ON w.id = ms.workspace_id
GROUP BY 
    w.id, w.name, w.fyle_org_id, 
    wgs.import_categories, wgs.import_items, wgs.charts_of_accounts, 
    wgs.import_tax_codes, wgs.import_vendors_as_merchants, wgs.import_code_fields, 
    gm.default_tax_code_name, gm.default_tax_code_id;
