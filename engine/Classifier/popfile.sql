-- POPFILE SCHEMA 1
-- ---------------------------------------------------------------------------------------------
--
-- popfile.schema - POPFile's database schema
--
-- Copyright (c) 2003-2004 John Graham-Cumming
--
--   This file is part of POPFile
--
--   POPFile is free software; you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation; either version 2 of the License, or
--   (at your option) any later version.
--
--   POPFile is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License
--   along with POPFile; if not, write to the Free Software
--   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
--
-- ---------------------------------------------------------------------------------------------

-- An ASCII ERD (you might like to find the 'users' table first and work from there)
--
--      +---------------+         +-----------------+
--      | user_template |         | bucket_template |
--      +---------------+         +-----------------+
--      |      id       |-----+   |       id        |---+
--      |     name      |     |   |      name       |   |
--      |     def       |     |   |       def       |   |
--      +---------------+     |   +-----------------+   |
--                            |                         |
--      +---------------+     |     +---------------+   |
--      |  user_params  |     |     | bucket_params |   |
--      +---------------+     |     +---------------+   |
--      |      id       |     |     |      id       |   |
--  +---|    userid     |     | +---|   bucketid    |   |
--  |   |     utid      |-----+ |   |     btid      |---+
--  |   |     val       |       |   |     val       |
--  |   +---------------+       |   +---------------+
--  |                           |                      +----------+
--  |                           |                      |  matrix  |      +-------+
--  |                           |   +---------+        +----------+      | words |
--  |      +----------+         |   | buckets |        |    id    |      +-------+
--  |      |   users  |         |   +---------+        |  wordid  |------|  id   |
--  |      +----------+      /--+---|    id   |=====---| bucketid |      |  word |
--  +----==|    id    |-----(-------| userid  |     \  |  times   |      +-------+
--      /  |   name   |     |       |  name   |     |  | lastseen |
--      |  | password |     |       | pseudo  |     |  +----------+
--      |  +----------+     |       +---------+     |
--      |                   |                       |
--      |                   |        +-----------+  |
--      |                   |        |  magnets  |  |
--      |   +------------+  |        +-----------+  |     +--------------+
--      |   |   history  |  |     +--|    id     |  |     | magnet_types |
--      |   +------------+  |     |  | bucketid  |--+     +--------------+
--      |   |     id     |  |     |  |   mtid    |--------|      id      |
--      +---|   userid   |  |     |  |   val     |        |     mtype    |
--          |   hdr_from |  |     |  |   seq     |        |    header    |
--          |   hdr_to   |  |     |  +-----------+        +--------------+
--          |   hdr_cc   |  |     |
--          | hdr_subject|  |     |
--          |  bucketid  |--+     |
--          |  usedtobe  |--/     |
--          |  magnetid  |--------+
--          |  hdr_date  |
--          | inserted   |
--          |    hash    |
--          | committed  |
--          +------------+
--

-- TABLE DEFINITIONS

-- ---------------------------------------------------------------------------------------------
--
-- popfile - data about the database
--
-- ---------------------------------------------------------------------------------------------

create table popfile ( id integer primary key,
                       version integer         -- version number of this schema
                     );

-- ---------------------------------------------------------------------------------------------
--
-- users - the table that stores the names and password of POPFile users
--
-- v0.21.0: With this release POPFile does not have an internal concept of
-- 'user' and hence this table consists of a single user called 'admin', once
-- we do the full multi-user release of POPFile this table will be used and
-- there will be suitable APIs and UI to modify it
--
-- ---------------------------------------------------------------------------------------------

create table users ( id integer primary key,  -- unique ID for this user
                     name varchar(255),       -- textual name of the user
                     password varchar(255),   -- user's password
                     unique (name)            -- the user name must be unique
                   );

-- ---------------------------------------------------------------------------------------------
--
-- buckets - the table that stores the name of POPFile buckets and relates
--           them to users. 
--
-- Note: A single user may have multiple buckets, but a single bucket only has
-- one user.  Hence there is a many-to-one relationship from buckets to users.
--
-- ---------------------------------------------------------------------------------------------

create table buckets( id integer primary key, -- unique ID for this bucket
                      userid integer,         -- corresponds to an entry in
                                              -- the users table
                      name varchar(255),      -- the name of the bucket
                      pseudo int,             -- 1 if this is a pseudobucket
                                              -- (i.e. one POPFile uses internally)
                      unique (userid,name)    -- a user can't have two buckets
                                              -- with the same name
                    );

-- ---------------------------------------------------------------------------------------------
--
-- words - the table that creates a unique ID for a word.  
--
-- Words and buckets come together in the matrix table to form the corpus of words for
-- each user.
--
-- ---------------------------------------------------------------------------------------------

create table words(   id integer primary key, -- unique ID for this word
                      word varchar(255),      -- the word
                      unique (word)           -- each word is unique
                  );

-- ---------------------------------------------------------------------------------------------
--
-- matrix - the corpus that consists of buckets filled with words.  Each word
--          in each bucket has a word count.
--
-- ---------------------------------------------------------------------------------------------

create table matrix( id integer primary key,   -- unique ID for this entry
                     wordid integer,           -- an ID in the words table
                     bucketid integer,         -- an ID in the buckets table
                     times integer,            -- number of times the word has
                                               -- been seen
                     lastseen date,            -- last time the record was read
                                               -- or written
                     unique (wordid, bucketid) -- each word appears once in a bucket 
                   );

-- ---------------------------------------------------------------------------------------------
--
-- user_template - the table of possible parameters that a user can have.  
--
-- For example in the users table there is just an password associated with
-- the user.  This table provides a flexible way of creating per user
-- parameters. It stores the definition of the parameters and the the
-- user_params table relates an actual user with each parameter
--
-- ---------------------------------------------------------------------------------------------

create table user_template( id integer primary key,  -- unique ID for this entry
                          name varchar(255),         -- the name of the
                                                     -- parameter
                          def varchar(255),          -- the default value for
                                                     -- the parameter
                          unique (name)              -- parameter name's are unique 
                        );

-- ---------------------------------------------------------------------------------------------
--
-- user_params - the table that relates users with user parameters (as defined
--               in user_template) and specific values.
--
-- ---------------------------------------------------------------------------------------------

create table user_params( id integer primary key,    -- unique ID for this
                                                     -- entry
                          userid integer,            -- a user
                          utid integer,              -- points to an entry in 
                                                     -- user_template
                          val varchar(255),          -- value for the
			                             -- parameter
                          unique (userid, utid)      -- each user has just one
			                             -- instance of each parameter
                        );
 
-- ---------------------------------------------------------------------------------------------
--
-- bucket_template - the table of possible parameters that a bucket can have.  
--
-- See commentary for user_template for an explanation of the philosophy
--
-- ---------------------------------------------------------------------------------------------

create table bucket_template( id integer primary key,  -- unique ID for this entry
                              name varchar(255),       -- the name of the
                                                       -- parameter
                              def varchar(255),        -- the default value for
                                                       -- the parameter
                              unique (name)            -- parameter name's are unique 
                            );

-- ---------------------------------------------------------------------------------------------
--
-- bucket_params - the table that relates buckets with bucket parameters (as defined
--                 in bucket_template) and specific values.
--
-- ---------------------------------------------------------------------------------------------

create table bucket_params( id integer primary key,    -- unique ID for this
                                                       -- entry
                            bucketid integer,          -- a bucket
                            btid integer,              -- points to an entry in 
                                                       -- bucket_template
                            val varchar(255),          -- value for the
			                               -- parameter
                            unique (bucketid, btid)    -- each bucket has just one
			                               -- instance of each parameter
                        );

-- ---------------------------------------------------------------------------------------------
--
-- magnet_types - the types of possible magnet and their associated header
--
-- ---------------------------------------------------------------------------------------------

create table magnet_types( id integer primary key,  -- unique ID for this entry
                           mtype varchar(255),      -- the type of magnet
                                                    -- (e.g. from)
                           header varchar(255),     -- the header (e.g. From)
                           unique (mtype)           -- types are unique
                         );

-- ---------------------------------------------------------------------------------------------
--
-- magnets - relates specific buckets to specific magnet types with actual
-- magnet values
--
-- ---------------------------------------------------------------------------------------------

create table magnets( id integer primary key,    -- unique ID for this entry
                      bucketid integer,          -- a bucket
                      mtid integer,              -- the magnet type
                      val varchar(255),          -- value for the magnet
                      comment varchar(255),      -- user defined comment
                      seq integer                -- used to set the order of magnets
                    );

-- ---------------------------------------------------------------------------------------------
--
-- history - this table contains the items in the POPFile history that
-- are managed by POPFile::History
--
-- ---------------------------------------------------------------------------------------------

create table history( id integer primary key,    -- unique ID for this entry
                      userid integer,            -- which user owns this
                      committed integer,         -- 1 if this item has been committed
                      hdr_from    varchar(255),  -- The From: header            
                      hdr_to      varchar(255),  -- The To: header            
                      hdr_cc      varchar(255),  -- The Cc: header            
                      hdr_subject varchar(255),  -- The Subject: header
                      hdr_date    date,          -- The Date: header
                      hash        varchar(255),  -- MD5 message hash
                      inserted    date,          -- When this was added
                      bucketid integer,          -- Current classification
                      usedtobe integer,          -- Previous classification
                      magnetid integer           -- If classified with magnet
                    );

-- MySQL SPECIFIC 

-- ---------------------------------------------------------------------------------------------
--
-- NOTE: The following alter table statements are required by MySQL in order
--       to get the ID fields to auto_increment on inserts.
--
-- ---------------------------------------------------------------------------------------------

alter table buckets modify id int(11) auto_increment;
alter table bucket_param modify id int(11) auto_increment;
alter table bucket_template modify id int(11) auto_increment;
alter table magnets modify id int(11) auto_increment;
alter table magnet_types modify id int(11) auto_increment;
alter table matrix modify id int(11) auto_increment;
alter table user_params modify id int(11) auto_increment;
alter table user_template modify id int(11) auto_increment;
alter table users modify id int(11) auto_increment;
alter table words modify id int(11) auto_increment;
alter table words modify word binary(255);
alter table history modify id int(11) auto_increment;

-- TRIGGERS

-- ---------------------------------------------------------------------------------------------
--
-- delete_bucket - if a/some bucket(s) are delete then this trigger ensures
--                 that entries the hang off the bucket table are also deleted
--
-- It deletes the related entries in the 'matrix', 'bucket_params' and
-- 'magnets' tables.  
--
-- ---------------------------------------------------------------------------------------------
 
create trigger delete_bucket delete on buckets
             begin
                 delete from matrix where bucketid = old.id;
                 delete from history where bucketid = old.id;
                 delete from magnets where bucketid = old.id;
                 delete from bucket_params where bucketid = old.id;
             end;

-- ---------------------------------------------------------------------------------------------
--
-- delete_user - deletes entries that are related to a user
--
-- It deletes the related entries in the 'matrix' and 'user_params'.
--
-- ---------------------------------------------------------------------------------------------

create trigger delete_user delete on users
             begin
                 delete from history where userid = old.id;
                 delete from buckets where userid = old.id;
                 delete from user_params where userid = old.id;
             end;

-- ---------------------------------------------------------------------------------------------
--
-- delete_magnet_type - handles the removal of a magnet type (this should be a
--                      very rare thing)
--
-- ---------------------------------------------------------------------------------------------

create trigger delete_magnet_type delete on magnet_types
             begin
                 delete from magnets where mtid = old.id;
             end;

-- ---------------------------------------------------------------------------------------------
--
-- delete_user_template - handles the removal of a type of user parameters
--
-- ---------------------------------------------------------------------------------------------

create trigger delete_user_template delete on user_template
             begin
                 delete from user_params where utid = old.id;
             end;

-- ---------------------------------------------------------------------------------------------
--
-- delete_bucket_template - handles the removal of a type of bucket parameters
--
-- ---------------------------------------------------------------------------------------------

create trigger delete_bucket_template delete on bucket_template
             begin
                 delete from bucket_params where btid = old.id;
             end;

-- Default data

-- This is schema version 1

insert into popfile ( version ) values ( 1 );

-- There's always a user called 'admin'

insert into users ( name, password ) values ( 'admin', 'e11f180f4a31d8caface8e62994abfaf' );

-- These are the possible parameters for a bucket
--
-- subject      1 if should do subject modification for message classified to this bucket
-- xtc          1 if should add X-Text-Classification header
-- xpl          1 if should add X-POPFile-Link header
-- fncount      Number of messages that were incorrectly classified, and meant to go into
--                  this bucket but did not
-- fpcount      Number of messages that were incorrectly classified into this bucket
-- quarantine   1 if should quaratine (i.e. RFC822 wrap) messages in this bucket
-- count        Total number of messages classified into this bucket
-- color        The color used for this bucket in the UI

insert into bucket_template ( name, def ) values ( 'subject',    '1' ); 
insert into bucket_template ( name, def ) values ( 'xtc',        '1' );
insert into bucket_template ( name, def ) values ( 'xpl',        '1' );
insert into bucket_template ( name, def ) values ( 'fncount',    '0' );
insert into bucket_template ( name, def ) values ( 'fpcount',    '0' );
insert into bucket_template ( name, def ) values ( 'quarantine', '0' );
insert into bucket_template ( name, def ) values ( 'count',      '0' );
insert into bucket_template ( name, def ) values ( 'color',      'black' );

-- The possible magnet types

insert into magnet_types ( mtype, header ) values ( 'from',    'From'    );
insert into magnet_types ( mtype, header ) values ( 'to',      'To'      );
insert into magnet_types ( mtype, header ) values ( 'subject', 'Subject' );
insert into magnet_types ( mtype, header ) values ( 'cc',      'Cc'      );

-- There's always a bucket called 'unclassified' which is where POPFile puts
-- messages that it isn't sure about.

insert into buckets ( name, pseudo, userid ) values ( 'unclassified', 1, 1 );

-- END

