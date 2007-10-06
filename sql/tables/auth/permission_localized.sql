
CREATE TABLE auth.permission_localized (
  permission TEXT NOT NULL,
  translated_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY( permission, translated_id ),
  FOREIGN KEY( permission ) REFERENCES auth.permission( permission ) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY( translated_id ) REFERENCES language( language_id ) ON UPDATE CASCADE ON DELETE CASCADE
);
