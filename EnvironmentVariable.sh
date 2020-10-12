#!/bin/bash
set -e

###### 初始全局变量 ######
JAVA_ENVIRONMENT_FILE_NAME='java_environment'

ENVIRONMENT_PATH='/etc/profile.d'

###### 判断是否安装java ######
if [ $(command -v java) ]; then
  echo "java 环境已安装"
  exit 0
fi

###### 创建文件 ######
if [ -f "$ $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh" ]; then
  $(rm -rf $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh)
fi
$(touch $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh)

#jdk版本下载路径变量(选择)
JDK_FILE_NAME=""
JDK_FILE_NAME_TAR=""
JDK_INSTALL_FILE_NAME=""

# shellcheck disable=SC2120
jdkVersionSwitch() {
  echo -n "请输入上面数字进行操作[默认:1] : "
  read i
  if [ x$i == x ]; then
    i=1
  fi
  if [ $i == 1 ]; then
    JDK_FILE_NAME='jdk-8u261-linux-i586'
    JDK_INSTALL_FILE_NAME='jdk1.8.0_261'
  elif [ $i == 2 ]; then
    JDK_FILE_NAME='jdk-11.0.8_linux-x64_bin'
    JDK_INSTALL_FILE_NAME='jdk11.0.8'
  else
    switchConfig
  fi

  JDK_DOWNLOAD_URL='https://github.com/mrhuanglearn/jdk_jar/releases/download/v1/'$JDK_FILE_NAME_TAR
  JDK_FILE_NAME_TAR=$JDK_FILE_NAME'.tar.gz'

  #支持安装32位软体
  if [ "$JDK_INSTALL_FILE_NAME" == 'jdk1.8.0_261' ] && [ $(rpm -q glibc.i686 | grep -cn glibc.i686) -ne 0 ]; then
    yum install -y glibc.i686
  fi

  #创建下载目录
  jdk_tmp='jdk_tmp'
  if [ ! -d /tmp/$jdk_tmp ]; then
    mkdir -p /tmp/$jdk_tmp
  fi
  #指定目录下载文件
  if [ ! -f "/tmp/$jdk_tmp/$JDK_FILE_NAME_TAR" ]; then
    wget -P /tmp/$jdk_tmp $JDK_DOWNLOAD_URL
  fi
}

jdkInstall() {
  if [ x$1 == x ]; then
    echo "安装路径为: / "
  else
    echo "安装路径为: $1 "
  fi

  if [ ! -f "/tmp/$jdk_tmp/$JDK_FILE_NAME_TAR" ]; then
    echo "未找到JDK安装文件"
    exit 1
  fi

  JDK_INSTALL_PATH="$1/$JDK_INSTALL_FILE_NAME"
  if [ -d $JDK_INSTALL_PATH ]; then
    rm -rf $JDK_INSTALL_PATH
  fi
  mkdir -p $JDK_INSTALL_PATH

  tar -zxf /tmp/$jdk_tmp/$JDK_FILE_NAME_TAR -C $JDK_INSTALL_PATH --strip-components 1
  rm -rf $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh
  echo 'export JAVA_HOME='$JDK_INSTALL_PATH'
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib' >>$ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh
}

cat <<F
  1.安装jdk1.8
  2.安装jdk11
F

######开始安装java环境######

#选择jdk版本
jdkVersionSwitch

read -p "请输入java安装位置[默认根目录(/)]:" java_path

#安装
jdkInstall $java_path

######重新加载环境变量######
$(source /etc/profile)
echo "安装完成!"
