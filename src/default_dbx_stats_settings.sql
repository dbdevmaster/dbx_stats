BEGIN
    dbx_stats_manager('DEBUGGING').set_setting('ENABLED'); -- defaul disable
    dbx_stats_manager('JOB_LOG_RETENTION').set_setting('7'); -- default 3 days
    dbx_stats_manager('MAX_JOB_DURATION').set_setting('4'); -- how long a specific dbms_scheduler is allowed to run in hours default 4h
    dbx_stats_manager('MAX_RUNTINE').set_setting('12'); -- max runtime of dbx_stats.gather_schema_stats overall default 6h
    dbx_stats_manager('JOB_AUTO_DROP').set_setting('TRUE'); -- default true
    dbx_stats_manager('JOB_PURGE_LOG').set_setting('TRUE'); -- default true
    dbx_stats_manager('TRACE').set_setting('FALSE'); -- default false
END;
/

