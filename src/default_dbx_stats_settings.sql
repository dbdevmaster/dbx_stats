DECLARE
    v_debugging dbx_stats_manager := dbx_stats_manager('DEBUGGING');
    v_job_log_retention dbx_stats_manager := dbx_stats_manager('JOB_LOG_RETENTION');
    v_max_job_duration dbx_stats_manager := dbx_stats_manager('MAX_JOB_DURATION');
    v_max_runtime dbx_stats_manager := dbx_stats_manager('MAX_RUNTIME');
    v_job_auto_drop dbx_stats_manager := dbx_stats_manager('JOB_AUTO_DROP');
    v_job_purge_log dbx_stats_manager := dbx_stats_manager('JOB_PURGE_LOG');
    v_trace dbx_stats_manager := dbx_stats_manager('TRACE');
BEGIN
    v_debugging.set_setting('ENABLED'); -- default disable
    v_job_log_retention.set_setting('7'); -- default 7 days
    v_max_job_duration.set_setting('4'); -- how long a specific dbms_scheduler job is allowed to run in hours, default 4h
    v_max_runtime.set_setting('12'); -- max runtime of dbx_stats.gather_schema_stats overall, default 6h
    v_job_auto_drop.set_setting('TRUE'); -- default true
    v_job_purge_log.set_setting('TRUE'); -- default true
    v_trace.set_setting('FALSE'); -- default false
END;
/

