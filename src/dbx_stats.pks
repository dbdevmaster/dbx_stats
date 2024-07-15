CREATE OR REPLACE PACKAGE dbx_stats AS

    FUNCTION is_trace_enabled RETURN BOOLEAN;
    FUNCTION is_debugging_enabled RETURN BOOLEAN;
    PROCEDURE debugging(p_message VARCHAR2);
    PROCEDURE create_watcher_job(v_start_time TIMESTAMP);
    PROCEDURE create_gather_job(p_job_name VARCHAR2, p_schema_name VARCHAR2, p_instance_number NUMBER, p_max_job_runtime NUMBER);
    PROCEDURE insert_job_record(p_schema_name VARCHAR2, p_job_name VARCHAR2, p_instance_number NUMBER, p_session_id VARCHAR2);
    PROCEDURE update_job_record(p_job_name VARCHAR2, p_status VARCHAR2, p_duration INTERVAL DAY TO SECOND DEFAULT NULL, p_dbms_scheduler_status VARCHAR2 DEFAULT NULL, p_dbms_scheduler_error NUMBER DEFAULT NULL, p_dbms_scheduler_info VARCHAR2 DEFAULT NULL);
    PROCEDURE gather_stale_objects(schema_name VARCHAR2, objlist OUT dbms_stats.objecttab);
    PROCEDURE gather_empty_objects(schema_name VARCHAR2, objlist OUT dbms_stats.objecttab);
    PROCEDURE drop_job(p_job_name VARCHAR2);
    PROCEDURE purge_log(p_job_name VARCHAR2);
    FUNCTION get_prefs_schema_tbls(v_schema_to_check VARCHAR2) RETURN dbx_pref_table PIPELINED;
    FUNCTION get_stale_stats_schema(v_schema_to_check VARCHAR2) RETURN dbx_stale_stats_table PIPELINED;
    PROCEDURE set_prefs(p_schema_name IN VARCHAR2, p_table_name IN VARCHAR2 DEFAULT NULL, p_pname IN VARCHAR2, p_value IN VARCHAR2);
    FUNCTION gather_schema_stats(p_schema_name IN VARCHAR2, p_degree IN INTEGER, p_cluster IN VARCHAR2 DEFAULT 'FALSE') RETURN dbx_job_table PIPELINED;
    FUNCTION get_job_status RETURN dbx_job_table PIPELINED;
    PROCEDURE clean_up_job_logs;
    PROCEDURE watch_jobs; -- Declare the watch_jobs procedure

END dbx_stats;
/

