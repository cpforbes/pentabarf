
BEGIN;

CREATE TABLE base.log_transaction_involved_tables (
  log_transaction_id INTEGER,
  table_name TEXT
);

CREATE TABLE log.log_transaction_involved_tables (
  FOREIGN KEY (log_transaction_id) REFERENCES log.log_transaction(log_transaction_id) ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY( log_transaction_id, table_name )
) INHERITS( base.log_transaction_involved_tables );

CREATE OR REPLACE FUNCTION log.log_transaction_involved_tables_before_insert() RETURNS trigger AS $$
  BEGIN
    PERFORM 1 FROM log.log_transaction_involved_tables WHERE log_transaction_id = NEW.log_transaction_id AND table_name = NEW.table_name;
    IF FOUND THEN
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_transaction_involved_tables_insert_trigger BEFORE INSERT ON log.log_transaction_involved_tables FOR EACH ROW EXECUTE PROCEDURE log.log_transaction_involved_tables_before_insert();

CREATE SCHEMA custom;

CREATE TABLE base.custom_fields (
  table_name TEXT NOT NULL,
  field_name TEXT NOT NULL,
  field_type TEXT NOT NULL,
  CHECK( table_name IN ('conference_person') ),
  CHECK( field_name ~* '^[a-z_0-9]+$' ),
  CHECK( field_type IN ('boolean','text') )
);

CREATE TABLE custom.custom_fields (
  PRIMARY KEY( table_name, field_name )
) INHERITS( base.custom_fields );

CREATE TABLE log.custom_fields (
) INHERITS( base.logging, base.custom_fields );

CREATE TABLE base.custom_conference_person (
  conference_person_id INTEGER NOT NULL
);

CREATE TABLE custom.custom_conference_person (
  PRIMARY KEY( conference_person_id ),
  FOREIGN KEY( conference_person_id) REFERENCES conference_person(conference_person_id) ON UPDATE CASCADE ON DELETE CASCADE
) INHERITS( base.custom_conference_person );

CREATE TABLE log.custom_conference_person (
) INHERITS( base.logging, base.custom_conference_person );

INSERT INTO ui_message VALUES ('table::conference_person_travel::accommodation_currency');
INSERT INTO ui_message_localized VALUES ('table::conference_person_travel::accommodation_currency','en','Currency');
INSERT INTO ui_message VALUES ('table::conference_person_travel::fee_currency');
INSERT INTO ui_message_localized VALUES ('table::conference_person_travel::fee_currency','en','Currency');
INSERT INTO ui_message VALUES ('table::conference_person_travel::travel_currency');
INSERT INTO ui_message_localized VALUES ('table::conference_person_travel::travel_currency','en','Currency');
INSERT INTO ui_message VALUES ('table::event_feedback::remark');
INSERT INTO ui_message_localized VALUES ('table::event_feedback::remark','en','Comment');
INSERT INTO ui_message VALUES ('table::ui_message::ui_message');
INSERT INTO ui_message_localized VALUES ('table::ui_message::ui_message','en','UI message');
INSERT INTO ui_message VALUES ('table::ui_message_localized::ui_message');
INSERT INTO ui_message_localized VALUES ('table::ui_message_localized::ui_message','en','UI message');
INSERT INTO ui_message VALUES ('table::ui_message_localized::name');
INSERT INTO ui_message_localized VALUES ('table::ui_message_localized::name','en','Name');
INSERT INTO ui_message VALUES ('table::ui_message_localized::translated');
INSERT INTO ui_message_localized VALUES ('table::ui_message_localized::translated','en','Language');

INSERT INTO auth.domain VALUES ('custom');
INSERT INTO auth.permission VALUES ('modify_custom');
INSERT INTO auth.role_permission VALUES ('admin','modify_custom');
INSERT INTO auth.role_permission VALUES ('developer','modify_custom');
INSERT INTO auth.object_domain VALUES ('custom_fields','custom');
INSERT INTO auth.object_domain VALUES ('custom_conference_person','person');

CREATE TRIGGER custom_fields_trigger BEFORE INSERT OR UPDATE OR DELETE ON custom.custom_fields FOR EACH ROW EXECUTE PROCEDURE custom_field_trigger();

ALTER TABLE base.conference_person ADD COLUMN reconfirmed BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
