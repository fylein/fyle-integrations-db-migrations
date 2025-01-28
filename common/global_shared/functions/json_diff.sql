DROP FUNCTION if exists json_diff;

CREATE OR REPLACE FUNCTION json_diff(left_json JSONB, right_json JSONB) RETURNS JSONB AS
$json_difference$
    SELECT jsonb_object_agg(left_table.key, jsonb_build_array(left_table.value, right_table.value)) FROM
        ( SELECT key, value FROM jsonb_each(left_json) ) left_table LEFT OUTER JOIN
        ( SELECT key, value FROM jsonb_each(right_json) ) right_table ON left_table.key = right_table.key
    WHERE left_table.value != right_table.value OR right_table.key IS NULL;
$json_difference$
    LANGUAGE sql;
