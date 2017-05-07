FROM alpine:3.5

MAINTAINER Juliano Petronetto <juliano.petronetto@gmail.com>

# Setup de basic requeriments
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools

# Installing numpy, pandas, scipy and scikit-learn
RUN apk add --no-cache tini libstdc++ && \
    apk add --no-cache \
        --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        lapack-dev && \
    apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gcc gfortran musl-dev \
        python3-dev && \
    ln -s locale.h /usr/include/xlocale.h && \
    pip install cython && \
    pip install numpy && \
    pip install pandas && \
    pip install scipy && \
    pip install scikit-learn

# Install jupyter notebook
RUN pip3 install jupyter \
   && pip3 install ipywidgets \
   && jupyter nbextension enable --py widgetsnbextension

# Cleaning
RUN pip uninstall --yes cython && \
    rm /usr/include/xlocale.h && \
    rm -r /root/.cache && \
    apk del .build-dependencies

# Create nbuser user with UID=1000 and in the 'users' group
# Grant ownership over the conda dir and home dir, but stick the group as root.
RUN adduser -G users -u 1000 -s /bin/sh -D nbuser \
    && echo "nbuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir /home/nbuser/notebooks \
    && mkdir /home/nbuser/.jupyter \
    && mkdir /home/nbuser/.local \
    && chown -R nbuser:users /home/nbuser

# Run notebook without token
RUN echo "c.NotebookApp.token = u''" >> ~/.jupyter/jupyter_notebook_config.py

# Start file
COPY start.sh /start.sh
RUN chmod a+x /start.sh

EXPOSE 8888

WORKDIR /home/nbuser/notebooks

USER nbuser

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/start.sh"]