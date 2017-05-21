#!/bin/sh

FILE=~/.ipython/profile_default/startup/disable-warnings.py

if [ "${WARNINGS}" = "enable" ]; then
    if [ -f $FILE ]; then
        rm $FILE
    fi
else
    echo -e "import warnings\nwarnings.filterwarnings('ignore')" >> $FILE
fi;

exec jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.token=