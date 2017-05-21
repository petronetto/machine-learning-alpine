#!/bin/sh
if [ "${WARNINGS}" = "enable" ]; then
    rm home/nbuser/.ipython/profile_default/startup/disable-warnings.py
fi;

exec jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.token=