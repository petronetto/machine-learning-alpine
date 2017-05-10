FROM alpine:3.5

MAINTAINER Juliano Petronetto <juliano.petronetto@gmail.com>

# Setup de basic requeriments
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 --no-cache-dir install --upgrade pip setuptools

# Installing numpy, pandas, scipy, xgboost, scikit-learn and jupyter
RUN apk add --no-cache tini libstdc++ gcc && \
    apk add --no-cache \
        --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        lapack-dev && \
    apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran musl-dev make \
        python3-dev && \
    ln -s locale.h /usr/include/xlocale.h && \
    pip --no-cache-dir install cython && \
    pip --no-cache-dir install numpy && \
    pip --no-cache-dir install pandas && \
    pip --no-cache-dir install scipy && \
    pip --no-cache-dir install scikit-learn && \
    pip --no-cache-dir install xgboost && \
    pip --no-cache-dir install jupyter

# Cleaning
RUN pip uninstall --yes cython && \
    rm /usr/include/xlocale.h && \
    rm -rf /root/.cache && \
    rm -rf /var/cache/apk/* && \
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
RUN echo "c.NotebookApp.token = u''" >> /home/nbuser/.jupyter/jupyter_notebook_config.py

# Start file
COPY start.sh /start.sh
RUN chmod a+x /start.sh

EXPOSE 8888

WORKDIR /home/nbuser/notebooks

USER nbuser

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/start.sh"]