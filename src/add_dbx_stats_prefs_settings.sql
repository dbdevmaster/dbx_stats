SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('APPROXIMATE_NDV_ALGORITHM', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('AUTO_STAT_EXTENSIONS', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('AUTO_TASK_STATUS', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('AUTO_TASK_MAX_RUN_TIME', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('AUTO_TASK_INTERVAL', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('CASCADE', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('CONCURRENT', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('DEGREE', 'Y'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('ESTIMATE_PERCENT', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('GLOBAL_TEMP_TABLE_STATS', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('GRANULARITY', 'Y'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('INCREMENTAL', 'Y'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('INCREMENTAL_STALENESS', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('INCREMENTAL_LEVEL', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('METHOD_OPT', 'Y'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('NO_INVALIDATE', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('OPTIONS', 'Y'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('PREFERENCE_OVERRIDES_PARAMETER', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('PUBLISH', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('STALE_PERCENT', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('STAT_CATEGORY', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('TABLE_CACHED_BLOCKS', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('WAIT_TIME_TO_UPDATE_STATUS', 'N'));
END;
/
