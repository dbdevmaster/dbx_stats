-- Create the package specification
CREATE OR REPLACE PACKAGE dbx_stats AS
    -- Functions and procedures
    FUNCTION get_prefs_schema_tbls(v_schema_to_check VARCHAR2) RETURN dbx_pref_table PIPELINED;
    FUNCTION get_stale_stats_schema(v_schema_to_check VARCHAR2) RETURN dbx_stale_stats_table PIPELINED;
    PROCEDURE set_prefs(
        p_schema_name  IN VARCHAR2,
        p_table_name   IN VARCHAR2 DEFAULT NULL,
        p_pname        IN VARCHAR2,
        p_value        IN VARCHAR2
    );
    FUNCTION gather_schema_stats(
        p_schema_name IN VARCHAR2,
        p_degree      IN INTEGER,
        p_cluster     IN VARCHAR2 DEFAULT 'FALSE'
    ) RETURN dbx_job_table PIPELINED;
    FUNCTION get_job_status RETURN dbx_job_table PIPELINED;
END dbx_stats;
/
