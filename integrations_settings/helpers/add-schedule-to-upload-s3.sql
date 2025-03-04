INSERT INTO django_q_schedule (func, args, schedule_type, minutes, next_run, repeats, cluster)
    SELECT 'apps.integrations.tasks.publish_to_rabbitmq', NULL, 'I', 60, NOW() + interval '1 minute', -1, 'import'
    WHERE NOT EXISTS (
        SELECT 1
        FROM django_q_schedule
        WHERE func = 'apps.integrations.tasks.publish_to_rabbitmq'
        AND args IS NULL
    );
