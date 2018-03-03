#Accept username to install under
if [ -z "$1" ]
then
	echo "You must provide a user to install hadoop."
	exit 1
fi

USER_NAME=$1


#Check that the install directory exists before installing
INSTALL_DIR="/home/${USER_NAME}"

if [ ! -d "$INSTALL_DIR" ]
then
	echo "Directory ${INSTALL_DIR} does not exist."
	exit 1
fi

#Install Java and dependencies
echo "Installing Dependencies"
sudo yum -y install java-1.7.0-openjdk
sudo yum -y install java-devel
sudo yum -y install wget

#Download Hadoop 2.7
echo "Downloading Hadoop 2.7.5"
sudo -u $USER_NAME wget http://mirror.cc.columbia.edu/pub/software/apache/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz -P /home/${USER_NAME}/

#Place Hadoop 2.7 in /usr/local/hadoop
echo "Moving Hadoop to /usr/local"
mkdir -p /usr/local/hadoop
tar -zxvf /home/${USER_NAME}/hadoop-2.7.5.tar.gz -C /usr/local/hadoop
chown -R $USER_NAME:$USER_NAME /usr/local/hadoop

#Replace JAVA_HOME in hadoop installation
echo "Setting JAVA_HOME for Hadoop"
JRE=`rpm -q java-1.7.0-openjdk`
JAVA="\/usr\/lib\/jvm\/${JRE}\/jre"

sed -i "s/#export JAVA_HOME=\${JAVA_HOME}/export JAVA_HOME=${JAVA}/g" /usr/local/hadoop/hadoop-2.7.5/etc/hadoop/hadoop-env.sh

#Make NN and DN Directory
echo "Creating Hadoop Namenode and Datanode Directories"
mkdir -p /usr/local/hdfs/namenode
mkdir -p /usr/local/hdfs/datanode
chown -R $USER_NAME:$USER_NAME /usr/local/hdfs/namenode
chown -R $USER_NAME:$USER_NAME /usr/local/hdfs/datanode

#Set up hadoop bash variables
echo "Setting up environment variables"
sed "s/JRE_PATH/${JAVA}/g" hadoop_bash >> /home/$USER_NAME/.bashrc
source /home/$USER_NAME/.bashrc

#Set up hadoop configuration files
echo "Setting up Hadoop configuration files"
sudo -u $USER_NAME cat core-site.xml > /usr/local/hadoop/hadoop-2.7.5/etc/hadoop/core-site.xml
sudo -u $USER_NAME cat mapred-site.xml > /usr/local/hadoop/hadoop-2.7.5/etc/hadoop/mapred-site.xml
sudo -u $USER_NAME cat hdfs-site.xml > /usr/local/hadoop/hadoop-2.7.5/etc/hadoop/hdfs-site.xml
sudo -u $USER_NAME cat yarn-site.xml > /usr/local/hadoop/hadoop-2.7.5/etc/hadoop/yarn-site.xml

#Set up passwordless ssh for localhost
echo "Setting up passwordless authentication"
sudo -u $USER_NAME ssh-keygen -t rsa -f /home/${USER_NAME}/.ssh/id_rsa -N ""
sudo -u $USER_NAME cat /home/${USER_NAME}/.ssh/id_rsa.pub >> /home/${USER_NAME}/.ssh/authorized_keys
