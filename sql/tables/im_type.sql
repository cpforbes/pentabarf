
CREATE TABLE base.im_type (
  im_type TEXT NOT NULL,
  scheme TEXT,
  rank INTEGER
);

CREATE TABLE im_type (
  PRIMARY KEY (im_type)
) INHERITS( base.im_type );

CREATE TABLE log.im_type (
) INHERITS( base.logging, base.im_type );

CREATE INDEX log_im_type_im_type_idx ON log.im_type( im_type );
CREATE INDEX log_im_type_log_transaction_id_idx ON log.im_type( log_transaction_id );

