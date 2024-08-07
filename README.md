# dbx_stats
## Package Description

The `dbx_stats` package offers a range of procedures and functions to set preferences, gather schema statistics, and retrieve stale statistics. The package also includes tools for identifying and tracking the sessions running these operations using `DBMS_APPLICATION_INFO`.


## Table of Contents

- [Key Features](#key-features)
- [Package Description](#package-description)
- [Degree and Cluster Option in gather_schema_stats](#degree-and-cluster-option-in-gather_schema_stats)
- [Installation](#installation)
    - [Database user permission](#database-user-permissions)
- [Functions and Procedures](#functions-and-procedures)
    - [procedure parameter](<#procedure-parameter>)
    - [set_prefs](#set_prefs)
    - [get_prefs_schema_tbls](#get_prefs_schema_tbls)
    - [get_stale_stats_schema](#get_stale_stats_schema)
    - [gather_schema_stats](#gather_schema_stats)
    - [get_job_status](#get_job_status)
    - [enable](#enable)
    - [disable](#disbale)
- [Analytics](#analytics)
- [dbx_prefs_manager](#dbx_prefs_manager)
- [dbx_stats_manager](#dbx_stats_manager)
- [Identifying Sessions](#identifying-sessions)
- [Known Issues](#known-issues)
- [Oracle Support and Documentation](#oracle-support-and-documentation)
    - [Key Documents and Links](#key-documents-and-links)
    - [Summary](#summary)
- [Keywords](#keywords)

## Key Features

The `dbx_stats` package is designed to facilitate the management of Oracle database statistics, making it highly beneficial for database administrators. The key features include:

1. **Preferences Management**: Set and retrieve preferences for schemas and tables, including options for partitioned and non-partitioned tables.
2. **Statistics Gathering**: Efficiently gather schema statistics with parallel job execution and load balancing across cluster nodes.
3. **Job Management**: Create, run, update, and clean up jobs for gathering statistics, with detailed logging and status tracking.
4. **Debugging and Tracing**: Enable detailed debugging and error tracing to facilitate troubleshooting.
5. **Session Identification**: Use `DBMS_APPLICATION_INFO` for better tracking and identification of sessions running these functions.

These features allow database administrators to ensure the accuracy and performance of their database statistics, manage the workload efficiently, and troubleshoot any issues effectively.


## Degree and Cluster Option in gather_schema_stats

The `gather_schema_stats` function allows you to gather schema statistics in parallel using the degree and cluster options.

- **Degree**: Specifies the number of parallel jobs to run. This controls how many jobs can run concurrently on a single instance.
- **Cluster**: When set to TRUE, jobs are distributed across all available instances in the cluster. This helps in balancing the load across the cluster nodes.


## Installation

### Database user permissions
```sql
grant create job to <username>;
grant manage scheduler to <username>;
grant analyze any to <username>;
grant execute on dbms_auto_task_admin to <username>;
grant select on dba_tables to <username>;
grant select on dba_indexes to <username>;
grant select on dba_ind_statistics to <username>;
grant select on dba_tab_statistics to <username>;
grant select on v_$instance to <username>;
grant select on gv_$instance to <username>;
grant select on gv_$session to <username>;
grant select on dba_scheduler_running_jobs to <username>;
grant select on dba_scheduler_job_run_details <username>; 
grant select on dba_scheduler_jobs <username>; 

```

## Functions and Procedures

- **set_prefs**: Sets preferences for a specific schema and table.
- **get_prefs_schema_tbls**: Retrieves preferences for all schemas, a specific schema, or schemas matching a regular expression.
- **get_stale_stats_schema**: Retrieves stale statistics for a specific schema.
- **gather_schema_stats**: Gathers schema statistics and manages jobs to run in parallel.
- **get_job_status**: Retrieves the status of the currently running and queued jobs.
- **dbx_prefs_manager**: Manages preferences used by the `dbx_stats` package.
- **dbx_stats_manager**: Manages various settings used by the `dbx_stats` package.

### procedure parameter
- ***`__ALL__`***: will loop over all users which are not maintained by oracle 
- ***`__REGEXP__HR`***: will loop over all user which are not maintained by oracle and where the username contains `HR`
- ***`__REGEXP__^HR`***: will loop over all user which are not maintained by oracle and where the username starts with `^HR`

### set_prefs
Sets preferences for a specific schema and table.

- ***`p_schema_name`***
- ***`p_table_name`***: default null
- ***`p_pname`***
- ***`p_value`***
- ***`p_level`***: default 'SCHEMA'

```sql
-- Set preferences for a specific schema and table
BEGIN
    dbx_stats.set_prefs('MY_SCHEMA', 'MY_TABLE', 'DEGREE', '4');
END;
/
```

```sql
-- Set preferences for all non-Oracle maintained schemas
BEGIN
    dbx_stats.set_prefs('__ALL__', NULL, 'DEGREE', '4');
END;
/
```

```sql
-- Set preferences for schemas matching a regular expression
BEGIN
    dbx_stats.set_prefs('__REGEXP__HR', NULL, 'DEGREE', '4');
END;
/
```

### get_prefs_schema_tbls
Retrieves preferences for all schemas, a specific schema, or schemas matching a regular expression.

```sql
-- For all schemas
SELECT * FROM TABLE(dbx_stats.get_prefs_schema_tbls('__ALL__'));
```

```sql
-- For a specific schema
SELECT * FROM TABLE(dbx_stats.get_prefs_schema_tbls('HR'));
```

```sql
-- For schemas matching a regular expression
SELECT * FROM TABLE(dbx_stats.get_prefs_schema_tbls('__REGEXP__HR'));
```

### get_stale_stats_schema
Retrieves stale statistics for a specific schema.

```sql
SELECT * FROM TABLE(dbx_stats.get_stale_stats_schema('HR', 4));
```

### gather_schema_stats
Gathers schema statistics and manages jobs to run in parallel.

```sql
-- Gather statistics for a specific schema
SELECT * FROM TABLE(dbx_stats.gather_schema_stats('HR', 4, TRUE));
```

```sql
-- Gather statistics for all non-Oracle maintained schemas
SELECT * FROM TABLE(dbx_stats.gather_schema_stats('__ALL__', 4, TRUE));
```

```sql
-- Gather statistics for schemas matching a regular expression
SELECT * FROM TABLE(dbx_stats.gather_schema_stats('__REGEXP__HR', 4, TRUE));
```

```sql
SET SERVEROUTPUT ON
DECLARE
    CURSOR result_cursor IS
        SELECT schema_name, job_name, job_status, duration, instance_number
        FROM TABLE(dbx_stats.gather_schema_stats('HR', 4, 'TRUE'));
        
    v_result_row result_cursor%ROWTYPE;
BEGIN
    OPEN result_cursor;
    LOOP
        FETCH result_cursor INTO v_result_row;
        EXIT WHEN result_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Schema: ' || v_result_row.schema_name || 
                             ', Job Name: ' || v_result_row.job_name || 
                             ', Status: ' || v_result_row.job_status || 
                             ', Duration: ' || TO_CHAR(v_result_row.duration, 'HH24:MI:SS') || 
                             ', Instance: ' || v_result_row.instance_number);
    END LOOP;
    CLOSE result_cursor;
END;
/
```

### get_job_status
Retrieves the status of the currently running and queued jobs.

```sql
-- Get job status
SELECT * FROM TABLE(dbx_stats.get_job_status) order by 4 asc, 6;
```

### enable
Enable automatic statistics collection

```sql
set serveroutput on;
BEGIN
    dbx_stats.enable(
        p_schema_name => 'HR', -- or '__REGEXP__HR', 'HR'
        p_degree => 4,             -- Degree of parallelism
        p_force => TRUE,           -- Force recreate jobs and scheduler windows
        p_auto_task => FALSE       -- Disable auto_task statistics collection
    );
END;
/
```

### disable 
Disable automatic statistics collection


```sql
BEGIN
    dbx_stats.disable(
        schema_name => '__ALL__', -- or '__REGEXP__HR', 'HR'
        force => TRUE,           -- Force drop existing jobs and scheduler windows
        auto_task => TRUE        -- Enable auto_task statistics collection
    );
END;
/
```

### Analytics
Provides queries for analyzing the results of `dbx_stats` functions.

```sql
-- dbms_stats.get_prefs - group by schema
SELECT schema_name,
       object_type,
       partitioned,
       pref_name,
       LISTAGG(DISTINCT pref_value, ', ') WITHIN GROUP (ORDER BY pref_value) AS distinct_values
FROM TABLE(dbx_stats.get_prefs_schema_tbls('HR'))
GROUP BY schema_name,object_type, partitioned, pref_name
ORDER BY schema_name,object_type, partitioned, pref_name;
```

```sql
-- dbms_stats.gather_schema_stats (`LIST EMPTY` and `LIST STALE`) - schema level
SELECT 
    schema_name,
    object_type,
    partitioned,
    stale_stats,
    COUNT(*) AS status_count
FROM 
    TABLE(dbx_stats.get_stale_stats_schema('HR',4))
GROUP BY 
    schema_name, object_type, partitioned, stale_stats
ORDER BY 
    schema_name, object_type, partitioned, stale_stats;
```

```sql
-- dbms_stats.gather_schema_stats (`LIST EMPTY` and `LIST STALE`) - database level
SELECT 
    object_type,
    partitioned,
    stale_stats,
    COUNT(*) AS status_count
FROM 
    TABLE(dbx_stats.get_stale_stats_schema('HR',4))
GROUP BY 
    object_type, partitioned, stale_stats
ORDER BY 
    object_type, partitioned, stale_stats;
```
```sql
-- check gv$session
select inst_id,sid,username,schemaname,client_identifier,machine,program,module,action from gv$session where client_info like 'dbx_%';
```

### dbx_prefs_manager

The object type `dbx_prefs_manager` provides methods for adding, deleting, and updating preferences in the configuration table `dbx_stats_prefs`. This allows flexible management of preferences used by the `get_prefs_schema_tbls` function in the `dbx_stats` package.

#### Functions

- **add_pname(p_name VARCHAR2, p_enabled CHAR) RETURN VARCHAR2**:
  Adds a new preference to the `dbx_stats_prefs` table.
  - `p_name`: Name of the preference.
  - `p_enabled`: Status of the preference (`Y` for enabled, `N` for disabled).
  - Return value: A message indicating the success or failure of the operation.

- **delete_pname(p_name VARCHAR2) RETURN VARCHAR2**:
  Deletes a preference from the `dbx_stats_prefs` table.
  - `p_name`: Name of the preference to delete.
  - Return value: A message indicating the success or failure of the operation.

- **update_pname(p_name VARCHAR2, p_enabled CHAR) RETURN VARCHAR2**:
  Updates the status of a preference in the `dbx_stats_prefs` table.
  - `p_name`: Name of the preference.
  - `p_enabled`: New status of the preference (`Y` for enabled, `N` for disabled).
  - Return value: A message indicating the success or failure of the operation.

#### Available Preferences

- `APPROXIMATE_NDV_ALGORITHM`
- `AUTO_STAT_EXTENSIONS`
- `AUTO_TASK_STATUS`
- `AUTO_TASK_MAX_RUN_TIME`
- `AUTO_TASK_INTERVAL`
- `CASCADE`
- `CONCURRENT`
- `DEGREE`
- `ESTIMATE_PERCENT`
- `GLOBAL_TEMP_TABLE_STATS`
- `GRANULARITY`
- `INCREMENTAL`
- `INCREMENTAL_STALENESS`
- `INCREMENTAL_LEVEL`
- `METHOD_OPT`
- `NO_INVALIDATE`
- `OPTIONS`
- `PREFERENCE_OVERRIDES_PARAMETER`
- `PUBLISH`
- `STALE_PERCENT`
- `STAT_CATEGORY`
- `TABLE_CACHED_BLOCKS`
- `WAIT_TIME_TO_UPDATE_STATUS`

#### Example Usage

Here is an example of how to use the `dbx_prefs_manager` object type to add preferences:

```sql
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('APPROXIMATE_NDV_ALGORITHM', 'N'));
    DBMS_OUTPUT.PUT_LINE(dbx_prefs_manager.add_pname('DEGREE', 'Y'));
END;
/
```

### dbx_stats_manager
The dbx_stats_manager object type provides methods for managing settings used by the dbx_stats package. This allows flexible control over various settings such as debugging.

#### Functions
- ***set_setting(p_value VARCHAR2)*** : Sets the value of a setting.
    - ***`p_value`***: Value to set for the setting.
- ***get_setting RETURN VARCHAR2***: Retrieves the value of a setting.
    - **Return value***: The value of the setting.

##### Available settings

- `debugging`: Default value is 'FALSE'
- `job_log_retention`: Default value is 7
- `JOB_AUTO_DROP`: Default value is 'TRUE'
- `JOB_PURGE_LOG`: Default value is 'TRUE'
- `MAX_JOB_DURATION`: Default value is 120 (2 hours)
- `MAX_RUNTINE`: Default value is 360 (6 hours)

***Example Usage***
Here is an example of how to use the `dbx_stats_manager` object type to manage settings:

```sql
BEGIN
    dbx_stats_manager('DEBUGGING').set_setting('ENABLED');
END;
/
```

## Identifying Sessions
The package uses `DBMS_APPLICATION_INFO` to set `client_info`, `module`, and `action` for each session. This allows for better tracking and identification of the sessions running these functions.

```sql
-- Query to identify sessions running dbx_stats functions
SELECT 
    sid, 
    serial#, 
    username, 
    client_info, 
    module, 
    action
FROM 
    v$session
WHERE 
    client_info = 'dbx_stats_client'
    AND module = 'dbx_stats_module';
```

## Known Issues

because of (Doc ID 411960.1) for partitioned table there will be fixed values set for pname(s):
- ***`INCREMENTAL`*** -> `FALSE`
- ***`GRANULARITY`*** -> `DEFAULT`
- ***`OPTIONS`*** -> `GATHER`

## Oracle Support and Documentation


### Key Documents and Links

1. **STALE Column Of The DBA_IND_STATISTICS Is Not Updated When Gathered Statistics For Partitioned Tables**  
   - [Doc ID: 411960.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=411960.1)  
   - Description: This document addresses the issue where the STALE column in the DBA_IND_STATISTICS view is not updated correctly when statistics are gathered for partitioned tables.

2. **Gathering Optimizer Statistics**  
   - [Oracle Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/gathering-optimizer-statistics.html#GUID-C4F0B12B-2C9E-4050-B647-F7DC451D7878)  
   - Description: This guide provides detailed instructions on gathering optimizer statistics, which are essential for the Oracle Database to make informed decisions about query execution plans.

3. **FAQ: Automatic Statistics Collection**  
   - [Doc ID: 1233203.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1233203.1)  
   - Description: A comprehensive FAQ that covers various aspects of automatic statistics collection in Oracle databases, including best practices and troubleshooting tips.

4. **How to List the Objects with Stale Statistics Using dbms_stats.gather_schema_stats options=>'LIST STALE'**  
   - [Doc ID: 457666.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=457666.1)  
   - Description: This document explains how to use the `LIST STALE` option with the `dbms_stats.gather_schema_stats` procedure to identify objects with stale statistics.

5. **Oracle DBMS_STATS**
    - [Oracle Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_STATS.html)
    - Description: With the DBMS_STATS package you can view and modify optimizer statistics gathered for database objects.

6. **Hard Parse For Large Partitioned Table Is Very Slow (Doc ID 2486764.1)**
    - [Doc ID: 2486764.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2486764.1)
    - Description: Hard parse (first execution of SQL) for partitioned table that has a lot of partitions / subpartitions is very slow. 
                   (sql query seen during update statistics)

### Summary

These documents provide crucial information and guidelines for maintaining and troubleshooting statistics in Oracle databases. Ensuring up-to-date statistics is vital for database performance and efficient query execution.

## Keywords

- Oracle database
- Database statistics
- DBMS_STATS
- Oracle DBA tools
- Oracle performance tuning
- Schema statistics
- Partitioned tables
- Non-partitioned tables
- Oracle job management
- Oracle debugging
- Oracle tracing
- Oracle session identification
- Oracle clustering
- Oracle parallel execution
- Oracle preferences management
- Oracle job status tracking
- Oracle database optimization
- Oracle load balancing
