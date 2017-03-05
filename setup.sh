#!/bin/bash
#sudo apt-get install dos2unix
#downloads the package lists from the repositories and "updates" them to get information on the newest versions of packages
sudo apt-get update
#Install Oracle  JDK
echo "Installing Oracle JDK"
sudo wget -P /usr/local http://192.168.56.1/hadoop-installers/jdk-8u121-linux-x64.tar.gz 
echo "Untar the installer"
sudo tar -zxvf /usr/local/jdk-8u121-linux-x64.tar.gz --directory /usr/local

#install python. If you prefer to use python as programming language on hadoop
sudo apt-get install -y python

# install basic utilites like 
sudo apt-get install -y dos2unix
#Download hadoop
sudo wget -P /usr/local  http://192.168.56.1/hadoop-installers/hadoop-2.7.3.tar.gz 
#unzip hadoop binary
sudo tar -zxvf /usr/local/hadoop-2.7.3.tar.gz --directory /usr/local

#create a hadoop group
sudo groupadd hadoop
# crate hadoop user and add him to hadoop group
sudo useradd -m hadoop -g hadoop

#change the owner of the Hadoop files to be the hadoop user and group
sudo chown -R hadoop:hadoop /usr/local/hadoop-2.7.3

#Update JAVA_HOME and PATH
cat >> ~/.bashrc << EOD
export JAVA_HOME=/usr/local/jdk1.8.0_121
export PATH=\$JAVA_HOME/bin:\$PATH
export HADOOP_HOME=/usr/local/hadoop-2.7.3
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOD
#Run the bash profile
#source ~/.bashrc
export JAVA_HOME=/usr/local/jdk1.8.0_121
export PATH=$JAVA_HOME/bin:$PATH
export HADOOP_HOME=/usr/local/hadoop-2.7.3
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin


# create appropriate configuration files
cat > $HADOOP_HOME/etc/hadoop/core-site.xml << EOD
<?xml version="1.0"?>
<!-- core-site.xml -->
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://192.168.2.11/</value>
</property>
</configuration>
EOD

cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml << EOD
<?xml version="1.0"?>
<!-- hdfs-site.xml -->
<configuration>
<property>
<name>dfs.replication</name>
<value>1</value>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>/home/vagrant/hadoop/hdfs/datanode</value>
</property>
<property>
<name>dfs.namenode.name.dir</name>
<value>/home/vagrant/hadoop/hdfs/namenode</value>
</property>
</configuration>
EOD

cat > $HADOOP_HOME/etc/hadoop/mapred-site.xml << EOD
<?xml version="1.0"?>
<!-- mapred-site.xml -->
<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
</configuration>
EOD

cat > $HADOOP_HOME/etc/hadoop/yarn-site.xml << EOD
<?xml version="1.0"?>
<!-- yarn-site.xml -->
<configuration>
<property>
<name>yarn.resourcemanager.hostname</name>
<value>localhost</value>
</property>
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
</configuration>
EOD

#To enable passwordless login, generate a new SSH key with a key passphrase
ssh-keygen -t rsa -P 'hadoop' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#set JAVA_HOME
echo "export JAVA_HOME=$JAVA_HOME" | sudo  tee --append  $HADOOP_HOME/etc/hadoop/hadoop-env.sh > /dev/null

#Formatting the HDFS filesystem
hdfs namenode -format

#Start the HDFS, YARN, and MapReduce daemons
start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver


