-- POPFILE SCHEMA 4
-- ---------------------------------------------------------------------------
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
-- ---------------------------------------------------------------------------

-- An ASCII ERD (you might like to find the 'users' table first and work
-- from there)
--
--      +---------------+         +-----------------+
--      | user_template |         | bucket_template |
--      +---------------+         +-----------------+
--      |      id       |-----+   |       id        |---+
--      |     name      |     |   |      name       |   |
--      |     def       |     |   |       def       |   |
--      |     form      |     |   +-----------------+   |
--      +---------------+     |                         |
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
--  |                           |                      |  matrix  |   +-------+
--  |                           |   +---------+        +----------+   | words |
--  |      +----------+         |   | buckets |        |    id    |   +-------+
--  |      |   users  |         |   +---------+        |  wordid  |---|  id   |
--  |      +----------+      /--+---|    id   |=====---| bucketid |   |  word |
--  +----==|    id    |-----(-------| userid  |     \  |  times   |   +-------+
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
--          |    size    |
--          +------------+
--

-- TABLE DEFINITIONS

-- ---------------------------------------------------------------------------
--
-- popfile - data about the database
--
-- ---------------------------------------------------------------------------

create table popfile ( id integer primary key,
                       version integer         -- version number of this schema
                     );

-- ---------------------------------------------------------------------------
--
-- users - the table that stores the names and password of POPFile users
--
-- v0.21.0: With this release POPFile does not have an internal concept of
-- 'user' and hence this table consists of a single user called 'admin', once
-- we do the full multi-user release of POPFile this table will be used and
-- there will be suitable APIs and UI to modify it
--
-- ---------------------------------------------------------------------------

create table users ( id integer primary key,  -- unique ID for this user
                     name varchar(255),       -- textual name of the user
                     password varchar(255),   -- user's password
                     unique (name)            -- the user name must be unique
                   );

-- ---------------------------------------------------------------------------
--
-- buckets - the table that stores the name of POPFile buckets and relates
--           them to users. 
--
-- Note: A single user may have multiple buckets, but a single bucket only has
-- one user.  Hence there is a many-to-one relationship from buckets to users.
--
-- ---------------------------------------------------------------------------

create table buckets( id integer primary key, -- unique ID for this bucket
                      userid integer,         -- corresponds to an entry in
                                              -- the users table
                      name varchar(255),      -- the name of the bucket
                      pseudo int,             -- 1 if this is a pseudobucket
                                              -- (i.e. one POPFile uses
                                              -- internally)
                      unique (userid,name)    -- a user can't have two buckets
                                              -- with the same name
                    );

-- ---------------------------------------------------------------------------
--
-- words - the table that creates a unique ID for a word.  
--
-- Words and buckets come together in the matrix table to form the corpus of
-- words for each user.
--
-- ---------------------------------------------------------------------------

create table words(   id integer primary key, -- unique ID for this word
                      word varchar(255),      -- the word
                      unique (word)           -- each word is unique
                  );

-- ---------------------------------------------------------------------------
--
-- matrix - the corpus that consists of buckets filled with words.  Each word
--          in each bucket has a word count.
--
-- ---------------------------------------------------------------------------

create table matrix( id integer primary key,   -- unique ID for this entry
                     wordid integer,           -- an ID in the words table
                     bucketid integer,         -- an ID in the buckets table
                     times integer,            -- number of times the word has
                                               -- been seen
                     lastseen date,            -- last time the record was read
                                               -- or written
                     unique (wordid, bucketid) -- each word appears once in a bucket 
                   );

-- ---------------------------------------------------------------------------
--
-- user_template - the table of possible parameters that a user can have.  
--
-- For example in the users table there is just an password associated with
-- the user.  This table provides a flexible way of creating per user
-- parameters. It stores the definition of the parameters and the the
-- user_params table relates an actual user with each parameter
--
-- ---------------------------------------------------------------------------

create table user_template( id integer primary key, -- unique ID for this entry
                          name varchar(255),        -- the name of the
                                                    -- parameter
                          def varchar(255),         -- the default value for
                                                    -- the parameter
                          form varchar(255),        -- sprintf format string
                                                    -- defines display format
                                                    -- for parameter
                          unique (name)             -- parameter name's are
                                                    -- unique 
                        );

-- ---------------------------------------------------------------------------
--
-- user_params - the table that relates users with user parameters (as defined
--               in user_template) and specific values.
--
-- ---------------------------------------------------------------------------

create table user_params( id integer primary key, -- unique ID for this
                                                  -- entry
                          userid integer,         -- a user
                          utid integer,           -- points to an entry in 
                                                  -- user_template
                          val varchar(255),       -- value for the
                                                  -- parameter
                          unique (userid, utid)   -- each user has just one
                                                  -- instance of each parameter
                        );
 
-- ---------------------------------------------------------------------------
--
-- bucket_template - the table of possible parameters that a bucket can have.  
--
-- See commentary for user_template for an explanation of the philosophy
--
-- ---------------------------------------------------------------------------

create table bucket_template( id integer primary key,  -- unique ID for this
                                                       -- entry
                              name varchar(255),       -- the name of the
                                                       -- parameter
                              def varchar(255),        -- the default value for
                                                       -- the parameter
                              unique (name)            -- parameter names 
                                                       -- are unique 
                            );

-- ---------------------------------------------------------------------------
--
-- bucket_params - the table that relates buckets with bucket parameters 
--                 (as defined in bucket_template) and specific values.
--
-- ---------------------------------------------------------------------------

create table bucket_params( id integer primary key,   -- unique ID for this
                                                      -- entry
                            bucketid integer,         -- a bucket
                            btid integer,             -- points to an entry in 
                                                      -- bucket_template
                            val varchar(255),         -- value for the
                                                      -- parameter
                            unique (bucketid, btid)   -- each bucket has just 
                                                      -- one instance of each 
                                                      -- parameter
                        );

-- ---------------------------------------------------------------------------
--
-- magnet_types - the types of possible magnet and their associated header
--
-- ---------------------------------------------------------------------------

create table magnet_types( id integer primary key,  -- unique ID for this entry
                           mtype varchar(255),      -- the type of magnet
                                                    -- (e.g. from)
                           header varchar(255),     -- the header (e.g. From)
                           unique (mtype)           -- types are unique
                         );

-- ---------------------------------------------------------------------------
--
-- magnets - relates specific buckets to specific magnet types with actual
-- magnet values
--
-- ---------------------------------------------------------------------------

create table magnets( id integer primary key,    -- unique ID for this entry
                      bucketid integer,          -- a bucket
                      mtid integer,              -- the magnet type
                      val varchar(255),          -- value for the magnet
                      comment varchar(255),      -- user defined comment
                      seq integer                -- used to set the order of
                                                 -- magnets
                    );

-- ---------------------------------------------------------------------------
--
-- history - this table contains the items in the POPFile history that
-- are managed by POPFile::History
--
-- ---------------------------------------------------------------------------

create table history( id integer primary key,    -- unique ID for this entry
                      userid integer,            -- which user owns this
                      committed integer,         -- 1 if this item has been
                                                 -- committed
                      hdr_from    varchar(255),  -- The From: header 
                      hdr_to      varchar(255),  -- The To: header            
                      hdr_cc      varchar(255),  -- The Cc: header            
                      hdr_subject varchar(255),  -- The Subject: header
                      hdr_date    date,          -- The Date: header
                      hash        varchar(255),  -- MD5 message hash
                      inserted    date,          -- When this was added
                      bucketid integer,          -- Current classification
                      usedtobe integer,          -- Previous classification
                      magnetid integer,          -- If classified with magnet
                      sort_from   varchar(255),  -- The From: header 
                      sort_to     varchar(255),  -- The To: header            
                      sort_cc     varchar(255),  -- The Cc: header            
                      size        integer        -- Size of the message (bytes)
                    );

-- MySQL SPECIFIC 

-- ---------------------------------------------------------------------------
--
-- NOTE: The following alter table statements are required by MySQL in order
--       to get the ID fields to auto_increment on inserts.
--
-- ---------------------------------------------------------------------------

alter table buckets modify id int(11) auto_increment;
alter table bucket_params modify id int(11) auto_increment;
alter table bucket_template modify id int(11) auto_increment;
alter table magnets modify id int(11) auto_increment;
alter table magnet_types modify id int(11) auto_increment;
alter table matrix modify id int(11) auto_increment;
alter table user_params modify id int(11) auto_increment;
alter table user_template modify id int(11) auto_increment;
alter table users modify id int(11) auto_increment;
alter table words modify id int(11) auto_increment;
alter table history modify id int(11) auto_increment;
alter table popfile modify id int(11) auto_increment;

-- MySQL treats char fields as case insensitive for searches, in order to have
-- the same behavior as SQLite (case sensitive searches) we alter the word.word
-- field to binary, that will trick MySQL into treating it the way we want.

alter table words modify word binary(255);

-- MySQL enforces types, SQLite uses the concept of manifest typing, where 
-- the type of a value is associated with the value itself, not the column that
-- it is stored in. POPFile has two date fields in history where POPFile
-- is actually storing the unix time not a date. MySQL interprets the
-- unix time as a date of 0000-00-00, whereas SQLite simply stores the
-- unix time integer. The follow alter table statements redefine those
-- date fields as integer for MySQL so the correct behavior is obtained
-- for POPFile's use of the fields.

alter table history modify hdr_date int(11);
alter table history modify inserted int(11);

-- TRIGGERS

-- ---------------------------------------------------------------------------
--
-- delete_bucket - if a/some bucket(s) are delete then this trigger ensures
--                 that entries the hang off the bucket table are also deleted
--
-- It deletes the related entries in the 'matrix', 'bucket_params' and
-- 'magnets' tables.  
--
-- ---------------------------------------------------------------------------
 
create trigger delete_bucket delete on buckets
             begin
                 delete from matrix where bucketid = old.id;
                 delete from history where bucketid = old.id;
                 delete from magnets where bucketid = old.id;
                 delete from bucket_params where bucketid = old.id;
             end;

-- ---------------------------------------------------------------------------
--
-- delete_user - deletes entries that are related to a user
--
-- It deletes the related entries in the 'matrix' and 'user_params'.
--
-- ---------------------------------------------------------------------------

create trigger delete_user delete on users
             begin
                 delete from history where userid = old.id;
                 delete from buckets where userid = old.id;
                 delete from user_params where userid = old.id;
             end;

-- ---------------------------------------------------------------------------
--
-- delete_magnet_type - handles the removal of a magnet type (this should be a
--                      very rare thing)
--
-- ---------------------------------------------------------------------------

create trigger delete_magnet_type delete on magnet_types
             begin
                 delete from magnets where mtid = old.id;
             end;

-- ---------------------------------------------------------------------------
--
-- delete_user_template - handles the removal of a type of user parameters
--
-- ---------------------------------------------------------------------------

create trigger delete_user_template delete on user_template
             begin
                 delete from user_params where utid = old.id;
             end;

-- ---------------------------------------------------------------------------
--
-- delete_bucket_template - handles the removal of a type of bucket parameters
--
-- ---------------------------------------------------------------------------

create trigger delete_bucket_template delete on bucket_template
             begin
                 delete from bucket_params where btid = old.id;
             end;

-- Default data

-- This is schema version 4

insert into popfile ( version ) values ( 4 );

-- There's always a user called 'admin'

insert into users ( id, name, password ) values ( 1, 'admin', 'e11f180f4a31d8caface8e62994abfaf' );

insert into magnets ( id, bucketid, mtid, val, comment, seq ) values ( 0, 0, 0, '', '', 0 );

-- These are the possible parameters for a bucket
--
-- subject      1 if should do subject modification for message classified 
--              to this bucket
-- xtc          1 if should add X-Text-Classification header
-- xpl          1 if should add X-POPFile-Link header
-- fncount      Number of messages that were incorrectly classified, and 
--              meant to go into this bucket but did not
-- fpcount      Number of messages that were incorrectly classified into 
--              this bucket
-- quarantine   1 if should quaratine (i.e. RFC822 wrap) messages in this 
--              bucket
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

-- These are the possible per-user parameters

-- The user's public and private keys for history encryption
insert into user_template ( id, name, def, form ) values ( 1, 'GLOBAL_public_key', '', '%s' );
insert into user_template ( id, name, def, form ) values ( 2, 'GLOBAL_private_key', '', '%s' );

-- Set to 1 if the user is an administrator
insert into user_template ( id, name, def, form ) values ( 3, 'GLOBAL_can_admin', 0, '%d' );

-- The characters that appear before and after a subject modification
insert into user_template ( name, def, form ) values ( 'bayes_subject_mod_left', '[', '%s' );
insert into user_template ( name, def, form ) values ( 'bayes_subject_mod_right', ']', '%s' );

-- No default unclassified weight is the number of times more sure
-- POPFile must be of the top class vs the second class, default is
-- 100 times more
insert into user_template ( name, def, form ) values ( 'bayes_unclassified_weight', 100, '%d' );

-- If set to 1 then the X-POPFile-Link will have < > around the URL
-- (i.e. X-POPFile-Link: <http://foo.bar>) when set to 0 there are
-- none (i.e. X-POPFile-Link: http://foo.bar)
insert into user_template ( name, def, form ) values ( 'bayes_xpl_angle', 0, '%d' );

-- Keep the history for two days
insert into user_template ( name, def, form ) values ( 'history_history_days', 2, '%d' );

-- Checking for updates if off by default
insert into user_template ( name, def, form ) values ( 'html_update_check', 0, '%d' );

-- Sending of statistics is off
insert into user_template ( name, def, form ) values ( 'html_send_stats', 0, '%d' );

-- The size of a history page
insert into user_template ( name, def, form ) values ( 'html_page_size', 20, '%d' );

-- Use the default skin
insert into user_template ( name, def, form ) values ( 'html_skin', 'default', '%s' );

-- The last time we checked for an update using the local epoch
insert into user_template ( name, def, form ) values ( 'html_last_update_check', 1104192000, '%d' );

-- The last time (textual) that the statistics were reset
insert into user_template ( name, def, form ) values ( 'html_last_reset', 'Thu Sep  2 14:22:23 2004', '%s' );

-- We start by assuming that the user speaks English like the
-- perfidious Anglo-Saxons that we are... :-)
insert into user_template ( name, def, form ) values ( 'html_language', 'English', '%s' );

-- If this is 1 then when the language is loaded we will use the
-- language string identifier as the string shown in the UI.  This
-- is used to test whether which identifiers are used where.
insert into user_template ( name, def, form ) values ( 'html_test_language', 0, '%d' );

-- This setting defines what is displayed in the word matrix:
-- 'freq' for frequencies, 'prob' for probabilities, 'score' for
-- logarithmic scores, if blank then the word table is not shown
insert into user_template ( name, def, form ) values ( 'html_wordtable_format', '', '%s' );

-- The default columns to show in the History page.  The order here
-- is important, as is the presence of a + (show this column) or -
-- (hide this column) in the value.  By default we show everything
insert into user_template ( name, def, form ) values ( 'html_columns', '+inserted,+from,+to,-cc,+subject,-date,-size,+bucket,', '%s' );

-- An overriden date format set by the user, if empty then the
-- Locale_Date from the language file is used (see pretty_date__)
insert into user_template ( name, def, form ) values ( 'html_date_format', '', '%s' );

-- If you want session dividers
insert into user_template ( name, def, form ) values ( 'html_session_dividers', 1, '%d' );

-- The number of characters to show in each column in the history, if set
-- to 0 then POPFile tries to do this automatically
insert into user_template ( name, def, form ) values ( 'html_column_characters', 34, '%d' );

-- Two variables that tell us whether to show help items
-- concerning bucket setup and training. The bucket item
-- is displayed by default, when it is turned off, the
-- training item is shown.
insert into user_template ( name, def, form ) values ( 'html_show_bucket_help', 0, '%d' );
insert into user_template ( name, def, form ) values ( 'html_show_training_help', 1, '%d' );

-- TODO Deal with IMAP module

insert into user_template ( name, def, form ) values ( 'imap_bucket_folder_mappings', '', '%s' );
insert into user_template ( name, def, form ) values ( 'imap_expunge', 0, '%d' );
insert into user_template ( name, def, form ) values ( 'imap_hostname', '', '%s' );
insert into user_template ( name, def, form ) values ( 'imap_login', '', '%s' );
insert into user_template ( name, def, form ) values ( 'imap_password', '', '%s' );
insert into user_template ( name, def, form ) values ( 'imap_port', 143, '%d' );
insert into user_template ( name, def, form ) values ( 'imap_training_mode', 0, '%d' );
insert into user_template ( name, def, form ) values ( 'imap_uidnexts', '', '%s' );
insert into user_template ( name, def, form ) values ( 'imap_uidvalidities', '', '%s' );
insert into user_template ( name, def, form ) values ( 'imap_update_interval', 20, '%d' );
insert into user_template ( name, def, form ) values ( 'imap_use_ssl', 0, '%d' );
insert into user_template ( name, def, form ) values ( 'imap_watched_folders', 'INBOX', '%s' );

-- The adminisrator (user 1) can_admin

insert into user_params ( userid, utid, val ) values ( 1, 3, 1 );

-- MySQL insists that auto_increment fields start at 1. POPFile requires
-- a special magnet record with an id of 0 in order to work properly.
-- The following SQL statement will fix the inserted special record
-- on MySQL installs so the id is 0, the statement should do nothing
-- on SQLite installs since it will not satisfy the where clause.

update magnets set id = 0 where id = 1 and (bucketid = 0 and mtid = 0);

-- END

