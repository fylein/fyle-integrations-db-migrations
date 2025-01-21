DROP VIEW IF EXISTS ormq_count_view;

CREATE OR REPLACE VIEW ormq_count_view AS
select count(*), current_database() as database from django_q_ormq;
