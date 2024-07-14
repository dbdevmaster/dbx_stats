-- Define the object type for stale stats
CREATE OR REPLACE TYPE dbx_stale_stats_record AS OBJECT (
    schema_name VARCHAR2(128),
    object_type VARCHAR2(30),
    object_name VARCHAR2(128),
    partitioned VARCHAR2(1),
    partition_name VARCHAR2(30),
    stale_stats VARCHAR2(4000)
);
/

-- Define the table type for stale stats
CREATE OR REPLACE TYPE dbx_stale_stats_table AS TABLE OF dbx_stale_stats_record;
/

