/*
 * Copyright 1999-2018 Alibaba Group Holding Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = config_info   */
/******************************************/

CREATE TABLE config_info (
  id serial,
  data_id varchar(255) NOT NULL ,
  group_id varchar(255) DEFAULT NULL,
  content lvarchar(2000) NOT NULL ,
  md5 varchar(32) DEFAULT NULL ,
  gmt_create DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  gmt_modified DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL ,
  src_user lvarchar(2000) ,
  src_ip varchar(20) DEFAULT NULL ,
  app_name varchar(128) DEFAULT NULL,
  tenant_id varchar(128) DEFAULT '' ,
  c_desc lvarchar(256) DEFAULT NULL,
  c_use varchar(64) DEFAULT NULL,
  effect varchar(64) DEFAULT NULL,
  type varchar(64) DEFAULT NULL,
  c_schema lvarchar(2000),
  PRIMARY KEY (id)
) ;
CREATE unique INDEX idx_configinfo on config_info(data_id,group_id,tenant_id);
alter table config_info lock mode (row);

/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = config_info_aggr   */
/******************************************/

CREATE TABLE config_info_aggr (
  id bigserial,
  data_id varchar(255) NOT NULL ,
  group_id varchar(255) NOT NULL ,
  datum_id varchar(255) NOT NULL ,
  content lvarchar(2000) NOT NULL ,
  gmt_modified DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL ,
  app_name varchar(128) DEFAULT NULL,
  tenant_id varchar(128) DEFAULT '' ,
  PRIMARY KEY (id)
  );

create index idx_configinfoaggr on config_info_aggr (data_id,group_id,tenant_id,datum_id);
alter table config_info_aggr lock mode (row);
/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = config_info_beta   */
/******************************************/


CREATE TABLE config_info_beta (
  id bigserial,
  data_id varchar(255) NOT NULL ,
  group_id varchar(128) NOT NULL ,
  app_name varchar(128) DEFAULT NULL ,
  content lvarchar(2000) NOT NULL ,
  beta_ips lvarchar(1024) DEFAULT NULL ,
  md5 varchar(32) DEFAULT NULL,
  gmt_create DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  gmt_modified DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  src_user lvarchar(2000),
  src_ip varchar(20) DEFAULT NULL ,
  tenant_id varchar(128) DEFAULT '' ,
  PRIMARY KEY (id)
  );
create unique index idx_configinfobeta on config_info_beta (data_id,group_id,tenant_id);
alter table config_info_beta lock mode (row);
/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = config_info_tag   */
/******************************************/

CREATE TABLE config_info_tag (
  id bigserial,
  data_id varchar(255) NOT NULL,
  group_id varchar(128) NOT NULL,
  tenant_id varchar(128) DEFAULT '',
  tag_id varchar(128) NOT NULL ,
  app_name varchar(128) DEFAULT NULL ,
  content lvarchar(2000) NOT NULL ,
  md5 varchar(32) DEFAULT NULL ,
  gmt_create DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
    gmt_modified DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  src_user lvarchar(2000) ,
  src_ip varchar(20) ,
  PRIMARY KEY (id)
);
create unique index idx_configinfotag on config_info_tag (data_id,group_id,tenant_id,tag_id);

alter table config_info_tag lock mode (row);

/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = config_tags_relation   */
/******************************************/

CREATE TABLE config_tags_relation (
  id bigint NOT NULL ,
  tag_name varchar(128) NOT NULL,
  tag_type varchar(64) DEFAULT NULL ,
  data_id varchar(255) NOT NULL ,
  group_id varchar(128) NOT NULL ,
  tenant_id varchar(128) DEFAULT '' ,
  nid bigserial,
  PRIMARY KEY (nid)
);

create  unique index idx_configtagsrelation on config_tags_relation (id,tag_name,tag_type);
alter table config_tags_relation lock mode (row);
/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = group_capacity   */
/******************************************/

CREATE TABLE group_capacity (
  id bigserial,
  group_id varchar(128) NOT NULL DEFAULT '' ,
  quota bigint  NOT NULL DEFAULT 0 ,
  usage bigint  NOT NULL DEFAULT 0 ,
  max_size bigint  NOT NULL DEFAULT 0 ,
  max_aggr_count bigint  NOT NULL DEFAULT 0 ,
  max_aggr_size bigint  NOT NULL DEFAULT 0 ,
  max_history_count bigint  NOT NULL DEFAULT 0 ,
  gmt_create DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL ,
  gmt_modified DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  PRIMARY KEY (id)
);

create unique index idx_groupcapacity on group_capacity (group_id);
alter table group_capacity lock mode (row);


/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = his_config_info   */
/******************************************/

CREATE TABLE his_config_info (
  id bigint,
  nid bigserial,
  data_id varchar(255) NOT NULL,
  group_id varchar(128) NOT NULL,
  app_name varchar(128) DEFAULT NULL ,
  content lvarchar(2000) NOT NULL,
  md5 varchar(32) DEFAULT NULL,
  gmt_create DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  gmt_modified DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  src_user lvarchar(2000),
  src_ip varchar(20) DEFAULT NULL,
  op_type char(10) DEFAULT NULL,
  tenant_id varchar(128) DEFAULT '' ,
  PRIMARY KEY (nid)
);
create index idx_hisconfiginfo_gmt_create on his_config_info (gmt_create);
create index idx_hisconfiginfo_gmt_modified on his_config_info (gmt_modified);
create index idx_hisconfiginfo_data_id on his_config_info (data_id);
alter table his_config_info lock mode (row);



/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = tenant_capacity   */
/******************************************/

CREATE TABLE tenant_capacity (
  id bigserial,
  tenant_id varchar(128) NOT NULL DEFAULT '',
  quota bigint  NOT NULL DEFAULT 0,
  usage bigint  NOT NULL DEFAULT 0,
  max_size bigint  NOT NULL DEFAULT 0,
  max_aggr_count bigint  NOT NULL DEFAULT 0,
  max_aggr_size bigint  NOT NULL DEFAULT 0,
  max_history_count bigint  NOT NULL DEFAULT 0,
  gmt_create DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  gmt_modified DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND NOT NULL,
  PRIMARY KEY (id)
);
create unique index idx_tenantcapacity on tenant_capacity(tenant_id);
alter table tenant_capacity lock mode (row);

CREATE TABLE tenant_info (
  id bigserial,
  kp varchar(128) NOT NULL ,
  tenant_id varchar(128) default '',
  tenant_name varchar(128) default '' ,
  tenant_desc lvarchar(256) DEFAULT NULL,
  create_source varchar(32) DEFAULT NULL,
  gmt_create bigint NOT NULL,
  gmt_modified bigint NOT NULL,
  PRIMARY KEY (id)
);
create unique index idx_tenantinfo on tenant_info(kp,tenant_id);
alter table tenant_info lock mode (row);

CREATE TABLE users (
	username varchar(50) NOT NULL PRIMARY KEY,
	password lvarchar(500) NOT NULL,
	enabled boolean NOT NULL
);

alter table users lock mode (row);

CREATE TABLE roles (
	username varchar(50) NOT NULL,
	role varchar(50) NOT NULL
);
create unique index idx_roles on roles(username,role);
alter table roles lock mode (row);

CREATE TABLE permissions (
    role varchar(50) NOT NULL,
    resource varchar(255) NOT NULL,
    action varchar(8) NOT NULL
);
create unique index idx_permissions on permissions(role,resource,action);
alter table permissions lock mode (row);

INSERT INTO users (username, password, enabled) VALUES ('nacos', '$2a$10$EuWPZHzz32dJN7jexM34MOeYirDdFAZm2kuWj7VEOJhhZkDrxfvUu', 'T');

INSERT INTO roles (username, role) VALUES ('nacos', 'ROLE_ADMIN');
