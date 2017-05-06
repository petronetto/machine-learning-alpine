FROM alpine:3.5

MAINTAINER Juliano Petronetto <juliano.petronetto@gmail.com>

RUN apk --update --no-cache --repository http://dl-4.alpinelinux.org/alpine/edge/community add \
    bash \
    git \
    curl \
    wget \
    ca-certificates \
    bzip2 \
    unzip \
    sudo \
    libstdc++ \
    glib \
    libxext \
    libxrender \
    tini \ 
    make \
    g++ \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-2.23-r1.apk" -o /tmp/glibc.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-bin-2.23-r1.apk" -o /tmp/glibc-bin.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-i18n-2.23-r1.apk" -o /tmp/glibc-i18n.apk \
    && apk add --allow-untrusted /tmp/glibc*.apk \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && rm -Rf /tmp/glibc*apk /var/cache/apk/*

# Configure environment
ENV CONDA_DIR=/opt/conda CONDA_VER=4.0.5
ENV PATH=$CONDA_DIR/bin:$PATH SHELL=/bin/bash LANG=C.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH
ENV SHELL=/bin/bash
ENV NB_USER=nbuser
ENV NB_UID=1000 

# Install conda
RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \
    curl https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh  -o mconda.sh && \
    /bin/bash mconda.sh -f -b -p $CONDA_DIR && \
    rm mconda.sh && \
    $CONDA_DIR/bin/conda install --yes conda==${CONDA_VER}

# Install Python 3 packages
RUN conda install --quiet --yes \
	'pandas=0.17*' \
	'matplotlib=1.5*' \
	'seaborn=0.7*' \
	'graphviz=2.38.*' \
	'scikit-learn=0.17*'

# Add shortcuts to distinguish pip for python2 and python3 envs
RUN ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3

# Install XGBoost library
RUN XGBOOST_URL="https://github.com/dmlc/xgboost/archive/0.47.zip" && \
    XGBOOST_PATH="/opt/xgboost-0.47" && \
    XGBOOST_FILE="xgboost.zip" && \
    cd /opt && \
    wget -q $XGBOOST_URL -O $XGBOOST_FILE && \
    unzip $XGBOOST_FILE && rm $XGBOOST_FILE && cd $XGBOOST_PATH && \
    make && \
    cd python-package && \
    $CONDA_DIR/bin/python setup.py install && \
    apk del build-dependencies

# Install Jupyter notebook
# Create nbuser user with UID=1000 and in the 'users' group
# Grant ownership over the conda dir and home dir, but stick the group as root.
RUN adduser -s /bin/bash -u $NB_UID -D $NB_USER && \
    mkdir /home/$NB_USER/work \
    && mkdir /home/$NB_USER/.jupyter \
    && mkdir /home/$NB_USER/.local \
    && mkdir -p $CONDA_DIR \
    && chown -R $NB_USER:users $CONDA_DIR \
    && chown -R $NB_USER:users /home/$NB_USER \
    && su $NB_USER -c "conda install --yes \
    'notebook=4.0*' \
    terminado" \
    && su $NB_USER -c "conda clean -ya"

# Add local files as late as possible to avoid cache busting
COPY start-notebook.sh /usr/local/bin/
COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter

# Configure container startup
EXPOSE 8888
WORKDIR /home/$NB_USER/work
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]