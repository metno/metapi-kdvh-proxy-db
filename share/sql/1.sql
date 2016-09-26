CREATE FOREIGN TABLE t_elem_map_timeseries (
  ELEM_CODE varchar(15) not null,
  STNR BIGINT NOT NULL,
  FROMDATE TIMESTAMP not null,
  TODATE TIMESTAMP,
  TABLE_NAME varchar(22),
  STANDARD_NAME varchar(100),
  CELL_METHOD varchar(100),
  OBSERVATION_TIMESPAN varchar(50),
  TIME_OFFSET varchar(50),
  SENSOR_NR smallint,
  SENSOR_LEVEL smallint,
  AUDIT_DATO TIMESTAMP,
  ELEMENT_ID varchar(2000),
  LEVEL_UNIT varchar(100),
  FLAG_TABLE_NAME varchar(100),
  CODE_TABLE_NAME varchar(100),
  REFERENCE_TIME varchar(24),
  RESULT_TIMEINTERVAL varchar(5),
  INNER_CELL_METHOD varchar(100),
  LIMIT_INT decimal(5,2),
  COVERAGE_METHOD varchar(100),
  ELEMENT_COMPOSITION varchar(2000),
  HAS_ACCESS smallint,
  PERFORMANCE_CATEGORY varchar(100),
  EXPOSURE_CATEGORY varchar(100),
  ORG_TS_ELEM_TABLE varchar(100),
  UNIT varchar(20)
) SERVER KDVH OPTIONS (table  '(SELECT * FROM KPORTAL.T_ELEM_MAP_TIMESERIES)');


CREATE FOREIGN TABLE t_elem_obs (
 STNR BIGINT NOT NULL,
 ELEM_CODE varchar(16) not null,
 FDATO timestamp not null,
 TDATO timestamp,
 TABLE_NAME varchar(22) not null,
 FLAG_TABLE_NAME varchar(22),
 AUDIT_DATO timestamp
) SERVER KDVH OPTIONS (table 'T_ELEM_OBS');
