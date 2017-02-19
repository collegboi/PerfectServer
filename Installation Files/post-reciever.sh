#!/bin/bash
APP_NAME="MyAwesomeProject"  
USERNAME="collegboi"  
HOME="/home/collegboi"  
APP_FOLDER="PerfectServer/app"  
RUNNING_FOLDER="$HOME/running"  
GIT_FOLDER="$APP_FOLDER/.git"  
echo ""  
echo "---------------------------------------"  
echo "Running with the following config:"  
echo "Owner: $USERNAME"  
echo "Home folder: $HOME"  
echo "Application name: $APP_NAME"  
echo "Application folder: $APP_FOLDER"  
echo "Git folder: $GIT_FOLDER"  
echo "Running folder: $RUNNING_FOLDER"  
echo "---------------------------------------"  
echo ""  
echo "* Cleaning up previous commit"  
sudo rm -f $HOME/.build  
sudo rm -f $HOME/Packages

# Move files from commit to the main folder
echo "* Extracting files from current commit"  
git --work-tree=$APP_FOLDER --git-dir=$GIT_FOLDER checkout -f

# Switch to app folder
echo "* Switching to $APP_FOLDER"  
cd $APP_FOLDER

# Compile the app and move it to the correct folder
echo "* Starting to build Swift app"  
sudo swift build  
sudo chown -R $USERNAME.$USERNAME .build/ Packages

echo "* Stoping $APP_NAME"  
sudo supervisorctl stop $APP_NAME

if [ -f $APP_FOLDER/.build/debug/$APP_NAME ]; then  
    echo "* Copying $APP_FOLDER/.build/debug/* app to $RUNNING_FOLDER/"
    sudo cp -rf $APP_FOLDER/.build/debug/* $RUNNING_FOLDER/
fi  
if [ -d "$DIRECTORY" ]; then  
    echo "* Copying $APP_FOLDER/webroot folder to $RUNNING_FOLDER/webroot"
    sudo cp -rf $APP_FOLDER/webroot/* $RUNNING_FOLDER/webroot/
fi

echo "* Setting permissions"  
cd $HOME  
sudo chown -R $USERNAME.$USERNAME running

# Find and restart the previous process
echo "* Starting $APP_NAME"  
sudo supervisorctl start $APP_NAME