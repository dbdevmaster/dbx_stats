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
                  IF LOWER(SELF.setting_name) = 'debugging' THEN
                      RETURN 'FALSE';
                  ELSIF LOWER(SELF.setting_name) = 'job_log_retention' THEN
                      RETURN '7';
                  ELSIF LOWER(SELF.setting_name) = 'max_job_runtime' THEN
                      RETURN '120'; -- 2 hours
                  ELSIF LOWER(SELF.setting_name) = 'max_runtime' THEN
                      RETURN '360'; -- 6 hours
                  ELSIF LOWER(SELF.setting_name) = 'trace' THEN
                      RETURN 'FALSE';
                  ELSE
                      RAISE;
                  END IF;
          END;

          RETURN v_value;
      END get_setting;
  END;
  /

