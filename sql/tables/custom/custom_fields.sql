
CREATE TABLE base.custom_fields (
  table_name TEXT NOT NULL,
  field_name TEXT NOT NULL,
  field_type TEXT NOT NULL,
  submission_visible BOOL NOT NULL DEFAULT FALSE,
  submission_settable BOOL NOT NULL DEFAULT FALSE,
  CHECK( table_name IN ('conference_person','person','event','conference') ),
  CHECK( field_name ~* '^[a-z_0-9]+$' ),
  CHECK( field_type IN ('boolean','text','valuelist','conference-valuelist') )
);

CREATE TABLE custom.custom_fields (
  PRIMARY KEY( table_name, field_name )
) INHERITS( base.custom_fields );

CREATE TABLE log.custom_fields (
) INHERITS( base.logging, base.custom_fields );

CREATE INDEX log_custom_fields_table_name_field_name_idx ON log.custom_fields( table_name, field_name );
CREATE INDEX log_custom_fields_log_transaction_id_idx ON log.custom_fields( log_transaction_id );

