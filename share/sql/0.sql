CREATE TABLE configuration (
  configuration_id INT NOT NULL,
  applied_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  apply_script TEXT,
  revert_script TEXT
);

ALTER TABLE ONLY configuration
  ADD CONSTRAINT configuration_pkey PRIMARY KEY (configuration_id);
