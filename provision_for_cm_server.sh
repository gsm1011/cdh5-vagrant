#!/bin/bash
################## install mysql database for cloudera   ####################
#install mysql database for cloudera  BEFORE installing cloudera
#---------------------------------------------------------------
# ref http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Ent/latest/Cloudera-Manager-Installation-Guide/cmig_install_mysql.html#cmig_topic_5_5
sudo yum install -y mysql-server
service mysqld start

yum install -y mysql-connector-java

mysqladmin -u root password p@ssw0rd

# add root remote access
mysql -u root -pp@ssw0rd -e "CREATE USER 'root'@'%' IDENTIFIED BY 'p@ssw0rd';"
mysql -u root -pp@ssw0rd -e "GRANT ALL ON *.* TO 'root'@'%';"


# Recommended Settings
sed -i 's/symbolic-links=0/#symbolic-links=0/g' /etc/my.cnf
echo '' >> /etc/my.cnf
echo '# Recommended Settings for cloudera [mysqld]' >> /etc/my.cnf
echo 'transaction-isolation=READ-COMMITTED' >> /etc/my.cnf
echo 'key_buffer              = 16M' >> /etc/my.cnf
echo 'key_buffer_size         = 32M' >> /etc/my.cnf
echo 'max_allowed_packet      = 16M' >> /etc/my.cnf
echo 'thread_stack            = 256K' >> /etc/my.cnf
echo 'thread_cache_size       = 64' >> /etc/my.cnf
echo 'query_cache_limit       = 8M' >> /etc/my.cnf
echo 'query_cache_size        = 64M' >> /etc/my.cnf
echo 'query_cache_type        = 1' >> /etc/my.cnf
echo '# Important: see Configuring the Databases and Setting max_connections' >> /etc/my.cnf
echo 'max_connections         = 550' >> /etc/my.cnf
echo '# log-bin should be on a disk with enough free space' >> /etc/my.cnf
echo 'log-bin=/var/lib/mysql/logs/binary/mysql_binary_log' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '# For MySQL version 5.1.8 or later. Comment out binlog_format for older versions.' >> /etc/my.cnf
echo 'binlog_format           = mixed' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo 'read_buffer_size = 2M' >> /etc/my.cnf
echo 'read_rnd_buffer_size = 16M' >> /etc/my.cnf
echo 'sort_buffer_size = 8M' >> /etc/my.cnf
echo 'join_buffer_size = 8M' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '# InnoDB settings' >> /etc/my.cnf
echo 'innodb_file_per_table = 1' >> /etc/my.cnf
echo 'innodb_flush_log_at_trx_commit  = 2' >> /etc/my.cnf
echo 'innodb_log_buffer_size          = 64M' >> /etc/my.cnf
echo 'innodb_buffer_pool_size         = 4G' >> /etc/my.cnf
echo 'innodb_thread_concurrency       = 8' >> /etc/my.cnf
echo 'innodb_flush_method             = O_DIRECT' >> /etc/my.cnf
echo 'innodb_log_file_size = 512M' >> /etc/my.cnf

# Move the old InnoDB log files to a backup location
mkdir /var/lib/mysql/bak_orignal_log_file
mv /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile1 /var/lib/mysql/bak_orignal_log_file

#Creating the MySQL Databases for Cloudera Manager --------------------------
#Create a database for the Activity Monitor
mysql -u root -pp@ssw0rd -e "create database amon DEFAULT CHARACTER SET utf8;"
mysql -u root -pp@ssw0rd -e "grant all on amon.* TO 'amon'@'%' IDENTIFIED BY 'p@ssw0rd';"

#Create a database for the Service Monitor
mysql -u root -pp@ssw0rd -e "create database smon DEFAULT CHARACTER SET utf8;"
mysql -u root -pp@ssw0rd -e "grant all on smon.* TO 'smon'@'%' IDENTIFIED BY 'p@ssw0rd';"

#Create a database for the Report Manager
mysql -u root -pp@ssw0rd -e "create database rman DEFAULT CHARACTER SET utf8;"
mysql -u root -pp@ssw0rd -e "grant all on rman.* TO 'rman'@'%' IDENTIFIED BY 'p@ssw0rd';"

#Create a database for the Host Monitor.
mysql -u root -pp@ssw0rd -e "create database hmon DEFAULT CHARACTER SET utf8;"
mysql -u root -pp@ssw0rd -e "grant all on hmon.* TO 'hmon'@'%' IDENTIFIED BY 'p@ssw0rd';"

# to make sure mysql will start at boot
/sbin/chkconfig mysqld on
/sbin/chkconfig --list mysqld

#Create the Database for the Hive Metastore and Impala Catalog Daemon
mysql -u root -pp@ssw0rd -e "CREATE DATABASE metastore DEFAULT CHARACTER SET utf8;"
mysql -u root -pp@ssw0rd -e "CREATE USER 'hive'@'localhost' IDENTIFIED BY 'p@ssw0rd';"
mysql -u root -pp@ssw0rd -e "REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'localhost';"
mysql -u root -pp@ssw0rd -e "GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES,EXECUTE ON metastore.* TO 'hive'@'localhost'; FLUSH PRIVILEGES;"

# show hive user privileges
# mysql -u root -pp@ssw0rd -e "SHOW GRANTS FOR 'hive'@'localhost';"
# show hive's user metastore tables
# mysql -u hive -pp@ssw0rd -e "USE metastore; SHOW TABLES;"
# confirm hive server 2 is correctly running
# /usr/lib/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n username -p password -d org.apache.hive.jdbc.HiveDriver -e "show tables;"
#Create a database for the Oozie server.
# mysql -u root -pp@ssw0rd -e "create database oozie;"
# mysql -u root -pp@ssw0rd -e "create user 'oozie'@'localhost' IDENTIFIED BY 'p@ssw0rd';"
# mysql -u root -pp@ssw0rd -e "grant all privileges on oozie.* to 'oozie'@'localhost'; flush privileges"
#Create a database for Hue.
# mysql -u root -pp@ssw0rd -e "create database hue;"
# mysql -u root -pp@ssw0rd -e "create user 'hue'@'localhost' IDENTIFIED BY 'p@ssw0rd';"
# mysql -u root -pp@ssw0rd -e "grant all privileges on hue.* to 'hue'@'localhost'; flush privileges"

# Install cloudera manager server and agent.
yum install -y cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server
yum clean all
