DECLARE
    v_debugging dbx_stats_manager := dbx_stats_manager('DEBUGGING');
    v_job_log_retention dbx_stats_manager := dbx_stats_manager('JOB_LOG_RETENTION');
    v_max_job_duration dbx_stats_manager := dbx_stats_manager('MAX_JOB_DURATION');
    v_max_runtime dbx_stats_manager := dbx_stats_manager('MAX_RUNTIME');
    v_job_auto_drop dbx_stats_manager := dbx_stats_manager('JOB_AUTO_DROP');
    v_job_purge_log dbx_stats_manager := dbx_stats_manager('JOB_PURGE_LOG');
    v_fetch_limit dbx_stats_manager := dbx_stats_manager('FETCH_LIMIT');
    v_trace dbx_stats_manager := dbx_stats_manager('TRACE');
    v_schedule_window_monday dbx_stats_manager := dbx_stats_manager('SCHEDULE_WINDOW_MONDAY');
    v_schedule_window_tuesday dbx_stats_manager := dbx_stats_manager('SCHEDULE_WINDOW_TUESDAY');
    v_schedule_window_wednesday dbx_stats_manager := dbx_stats_manager('SCHEDULE_WINDOW_WEDNESDAY');
    v_schedule_window_thursday dbx_stats_manager := dbx_stats_manager('SCHEDULE_WINDOW_THURSDAY');
    v_schedule_window_friday dbx_stats_manager := dbx_stats_manager('SCHEDULE_WINDOW_FRIDAY');
    v_schedule_window_saturday dbx_stats_manager := dbx_stats_manager('SCHEDULE_WINDOW_SATURDAY');
    v_schedule_window_sunday dbx_stats_manager := dbx_stats_manager('SCHEDULE_WINDOW_SUNDAY');
BEGIN
    v_debugging.set_setting('ENABLED'); -- default disable
    v_job_log_retention.set_setting('7'); -- default 7 days
    v_max_job_duration.set_setting('4'); -- how long a specific dbms_scheduler job is allowed to run in hours, default 4h
    v_max_runtime.set_setting('12'); -- max runtime of dbx_stats.gather_schema_stats overall, default 6h
    v_job_auto_drop.set_setting('TRUE'); -- default true
    v_job_purge_log.set_setting('TRUE'); -- default true
    v_trace.set_setting('FALSE'); -- default false
    v_fetch_limit.set_setting('10000'); -- fetch limit

    -- Schedule window settings
    v_schedule_window_monday.set_setting('FREQ=DAILY;BYDAY=MON;BYHOUR=6;BYMINUTE=30;BYSECOND=0'); -- default
    v_schedule_window_tuesday.set_setting('FREQ=DAILY;BYDAY=TUE;BYHOUR=6;BYMINUTE=30;BYSECOND=0'); -- default
    v_schedule_window_wednesday.set_setting('FREQ=DAILY;BYDAY=WED;BYHOUR=6;BYMINUTE=30;BYSECOND=0'); -- default
    v_schedule_window_thursday.set_setting('FREQ=DAILY;BYDAY=THU;BYHOUR=6;BYMINUTE=30;BYSECOND=0'); -- default
    v_schedule_window_friday.set_setting('FREQ=DAILY;BYDAY=FRI;BYHOUR=6;BYMINUTE=30;BYSECOND=0'); -- default
    v_schedule_window_saturday.set_setting('FREQ=DAILY;BYDAY=SAT;BYHOUR=6;BYMINUTE=30;BYSECOND=0'); -- default
    v_schedule_window_sunday.set_setting('FREQ=DAILY;BYDAY=SUN;BYHOUR=6;BYMINUTE=30;BYSECOND=0'); -- default
END;
/

