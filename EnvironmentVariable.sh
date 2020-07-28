#!/bin/bash

###### 初始全局变量 ######
JAVA_ENVIRONMENT_FILE_NAME='java_environment';

ENVIRONMENT_PATH='/etc/profile.d'


###### 判断是否安装java ######
if [ `command -v java` ];then
echo "java 环境已安装"
exit 0
fi


###### 创建文件 ######
if [  -f "$ $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh" ]; then
    `rm -rf  $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh`
fi
`touch $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh`


######开始配置java环境######
read -p "请输入java安装位置:" java_path

echo 'export JAVA_HOME='$java_path'
export PATH=$JAVA_HOME/bin:$PATH 
export CLASSPATH=.:$JAVA_HOME/lib'>>  $ENVIRONMENT_PATH/$JAVA_ENVIRONMENT_FILE_NAME.sh

######重新加载环境变量######
`source /etc/profile`
