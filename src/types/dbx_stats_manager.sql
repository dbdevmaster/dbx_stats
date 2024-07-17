CREATE OR REPLACE TYPE dbx_stats_manager AS OBJECT (
  setting_name VARCHAR2(100),

  MEMBER PROCEDURE set_setting(p_value VARCHAR2),
  MEMBER FUNCTION get_setting RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY dbx_stats_manager AS
  MEMBER PROCEDURE set_setting(p_value VARCHAR2) IS
    v_lower_value VARCHAR2(100);
  BEGIN
    -- Convert the value to lowercase before storing
    v_lower_value := LOWER(p_value);

    UPDATE dbx_stats_settings
    SET setting_value = v_lower_value
    WHERE LOWER(setting_name) = LOWER(SELF.setting_name);

    IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO dbx_stats_settings (setting_name, setting_value)
      VALUES (LOWER(SELF.setting_name), v_lower_value);
    END IF;

    COMMIT;
  END set_setting;

  MEMBER FUNCTION get_setting RETURN VARCHAR2 IS
    v_value VARCHAR2(100);
  BEGIN
    BEGIN
      -- Handle case-insensitive query
      SELECT setting_value
      INTO v_value
      FROM dbx_stats_settings
      WHERE LOWER(setting_name) = LOWER(SELF.setting_name);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CASE LOWER(SELF.setting_name)
          WHEN 'debugging' THEN
            RETURN 'FALSE';
          WHEN 'job_log_retention' THEN
            RETURN '7';
          WHEN 'max_job_duration' THEN
            RETURN '120'; -- 2 hours
          WHEN 'max_runtime' THEN
            RETURN '360'; -- 6 hours
          WHEN 'trace' THEN
            RETURN 'FALSE';
          WHEN 'job_auto_drop' THEN
            RETURN 'TRUE';
          WHEN 'job_purge_log' THEN
            RETURN 'TRUE';
          WHEN 'schedule_window_monday' THEN
            RETURN 'FREQ=DAILY;BYDAY=MON;BYHOUR=6;BYMINUTE=30,BYSECOND=0';
          WHEN 'schedule_window_tuesday' THEN
            RETURN 'FREQ=DAILY;BYDAY=TUE;BYHOUR=6;BYMINUTE=30,BYSECOND=0';
          WHEN 'schedule_window_wednesday' THEN
            RETURN 'FREQ=DAILY;BYDAY=WED;BYHOUR=6;BYMINUTE=30,BYSECOND=0';
          WHEN 'schedule_window_thursday' THEN
            RETURN 'FREQ=DAILY;BYDAY=THU;BYHOUR=6;BYMINUTE=30,BYSECOND=0';
          WHEN 'schedule_window_friday' THEN
            RETURN 'FREQ=DAILY;BYDAY=FRI;BYHOUR=6;BYMINUTE=30,BYSECOND=0';
          WHEN 'schedule_window_saturday' THEN
            RETURN 'FREQ=DAILY;BYDAY=SAT;BYHOUR=6;BYMINUTE=30,BYSECOND=0';
          WHEN 'schedule_window_sunday' THEN
            RETURN 'FREQ=DAILY;BYDAY=SUN;BYHOUR=6;BYMINUTE=30,BYSECOND=0';
          ELSE
            RAISE;
        END CASE;
    END;

    RETURN v_value;
  END get_setting;
END;
/

