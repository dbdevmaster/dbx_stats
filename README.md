# dbx_stats

## Key Features

The `dbx_stats` package is designed to facilitate the management of Oracle database statistics, making it highly beneficial for database administrators. The key features include:

1. **Preferences Management**: Set and retrieve preferences for schemas and tables, including options for partitioned and non-partitioned tables.
2. **Statistics Gathering**: Efficiently gather schema statistics with parallel job execution and load balancing across cluster nodes.
3. **Job Management**: Create, run, update, and clean up jobs for gathering statistics, with detailed logging and status tracking.
4. **Debugging and Tracing**: Enable detailed debugging and error tracing to facilitate troubleshooting.
5. **Session Identification**: Use `DBMS_APPLICATION_INFO` for better tracking and identification of sessions running these functions.

These features allow database administrators to ensure the accuracy and performance of their database statistics, manage the workload efficiently, and troubleshoot any issues effectively.

## Package Description

The `dbx_stats` package offers a range of procedures and functions to set preferences, gather schema statistics, and retrieve stale statistics. The package also includes tools for identifying and tracking the sessions running these operations using `DBMS_APPLICATION_INFO`.

## Degree and Cluster Option in gather_schema_stats

The `gather_schema_stats` function allows you to gather schema statistics in parallel using the degree and cluster options.

- **Degree**: Specifies the number of parallel jobs to run. This controls how many jobs can run concurrently on a single instance.
- **Cluster**: When set to TRUE, jobs are distributed across all available instances in the cluster. This helps in balancing the load across the cluster nodes.


## Functions and Procedures

- **set_prefs**: Sets preferences for a specific schema and table.
- **get_prefs_schema_tbls**: Retrieves preferences for all schemas, a specific schema, or schemas matching a regular expression.
- **get_stale_stats_schema**: Retrieves stale statistics for a specific schema.
- **gather_schema_stats**: Gathers schema statistics and manages jobs to run in parallel.
- **get_job_status**: Retrieves the status of the currently running and queued jobs.
- **dbx_prefs_manager**: Manages preferences used by the `dbx_stats` package.
- **dbx_stats_manager**: Manages various settings used by the `dbx_stats` package.

## Installation

### Database user permissions
```sql
grant create job to <username>;
grant manage schedule to <username>;
grant analyze any to <username>;
```


### set_prefs
Sets preferences for a specific schema and table.

- ***`p_schema_name` 
- ***`p_table_name`: default null
- ***`p_pname`
- ***`p_value` 
- ***`p_level`: default 'SCHEMA'

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
SELECT * FROM TABLE(dbx_stats.get_stale_stats_schema('HR'));
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
SELECT * FROM TABLE(dbx_stats.get_job_status);
```

### Analytics
Provides queries for analyzing the results of `dbx_stats` functions.

```sql
-- dbms_stats.get_prefs - group by schema
SELECT schema_name,
       partitioned,
       pref_type,
       LISTAGG(DISTINCT pref_value, ', ') WITHIN GROUP (ORDER BY pref_value) AS distinct_values
FROM TABLE(dbx_stats.get_prefs_schema_tbls('HR'))
GROUP BY schema_name, partitioned, pref_type
ORDER BY schema_name, partitioned, pref_type;
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
    TABLE(dbx_stats.get_stale_stats_schema('HR'))
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
    TABLE(dbx_stats.get_stale_stats_schema('HR'))
GROUP BY 
    object_type, partitioned, stale_stats
ORDER BY 
    object_type, partitioned, stale_stats;
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
- ***`INCREMENTAL` -> `FALSE`
- ***`GRANULARITY` -> `DEFAULT`
- ***`OPTIONS` -> `GATHER`

## Oracle Support Documents

- STALE Column Of The DBA_IND_STATISTICS Is Not Updated When Gathered Statistics For Partitioned Tables (Doc ID 411960.1)
- [Gathering Optimizer Statistics](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/gathering-optimizer-statistics.html#GUID-C4F0B12B-2C9E-4050-B647-F7DC451D7878)
- [FAQ: Automatic Statistics Collection (Doc ID 1233203.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1233203.1)
- [How to List the Objects with Stale Statistics Using dbms_stats.gather_schema_stats options=>'LIST STALE' (Doc ID 457666.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=457666.1)
