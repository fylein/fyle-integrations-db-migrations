DROP VIEW IF EXISTS product_import_settings_view;
CREATE VIEW product_import_settings_view AS
SELECT
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    c.import_categories,
    c.import_tax_codes,
    c.import_vendors_as_merchants,
    c.import_code_fields,
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
    ) AS mapping_settings_array,
    -- Dependent Field Settings as Array of JSON Objects
    COALESCE(
        JSON_AGG(
            JSON_BUILD_OBJECT(
                'cost_code_field_name', dfs.cost_code_field_name,
                'cost_code_placeholder', dfs.cost_code_placeholder,
                'cost_type_field_name', dfs.cost_type_field_name,
                'cost_type_placeholder', dfs.cost_type_placeholder,
                'is_import_enabled', dfs.is_import_enabled
            )
        ) FILTER (WHERE dfs.workspace_id IS NOT NULL),
        '[]'
    ) AS dependent_field_settings_array
FROM
    workspaces w
JOIN
    configurations c ON w.id = c.workspace_id
JOIN
    general_mappings gm ON w.id = gm.workspace_id
LEFT JOIN
    mapping_settings ms ON w.id = ms.workspace_id
LEFT JOIN
    dependent_field_settings dfs ON w.id = dfs.workspace_id
GROUP BY
    w.id, w.name, w.fyle_org_id, 
    c.import_categories, c.import_tax_codes, c.import_vendors_as_merchants, c.import_code_fields, 
    gm.default_tax_code_name, gm.default_tax_code_id;
