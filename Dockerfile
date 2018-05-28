# BSD 3-Clause License
#
# Copyright (c) 2017, Juliano Petronetto
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM alpine:3.7

LABEL maintainer="Juliano Petronetto <juliano@petronetto.com.br>" \
      name="Machine Learning Alpine" \
      description="Almost anything that you need for machine learning in a small container." \
      url="https://hub.docker.com/r/petronetto/machine-learning-alpine" \
      vcs-url="https://github.com/petronetto/machine-learning-alpine" \
      vendor="Petronetto DevTech" \
      version="1.0"

ENV MAIN_PKGS="\
        tini curl ca-certificates python3 py3-numpy \
        py3-numpy-f2py freetype jpeg libpng libstdc++ \
        libgomp graphviz font-noto openssl" \
    BUILD_PKGS="\
        build-base linux-headers python3-dev cython-dev py-setuptools git \
        cmake jpeg-dev libffi-dev gfortran openblas-dev \
        py-numpy-dev freetype-dev libpng-dev libexecinfo-dev" \
    PIP_PKGS="\
        pyyaml pymkl cffi scikit-learn pandas \
        matplotlib ipywidgets notebook requests \
        pillow graphviz seaborn" \
    CONF_DIR="~/.ipython/profile_default/startup"

RUN set -ex; \
    apk update; \
    apk upgrade; \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories; \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories; \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories; \
    apk add --no-cache ${MAIN_PKGS}; \
    python3 -m ensurepip; \
    rm -r /usr/lib/python*/ensurepip; \
    pip3 --no-cache-dir install --upgrade pip setuptools wheel; \
    apk add --no-cache --virtual=.build-deps ${BUILD_PKGS}; \
    pip install -U --no-cache-dir ${PIP_PKGS}; \
    ln -sf pip3 /usr/bin/pip; \
    ln -sf /usr/bin/python3 /usr/bin/python; \
    ln -s locale.h /usr/include/xlocale.h; \
    mkdir /opt && cd /opt; \
    git clone --recursive https://github.com/dmlc/xgboost; \
    sed -i '/#define DMLC_LOG_STACK_TRACE 1/d' /opt/xgboost/dmlc-core/include/dmlc/base.h; \
    sed -i '/#define DMLC_LOG_STACK_TRACE 1/d' /opt/xgboost/rabit/include/dmlc/base.h; \
    cd /opt/xgboost; make -j4; \
    cd /opt/xgboost/python-package; \
    python setup.py install; \
    apk del .build-deps; \
    rm /usr/include/xlocale.h; \
    rm -rf /root/.cache; \
    rm -rf /root/.[acpw]*; \
    rm -rf /var/cache/apk/*; \
    find /usr/lib/python3.6 -name __pycache__ | xargs rm -r; \
    jupyter nbextension enable --py widgetsnbextension; \
    mkdir -p ${CONF_DIR}/; \
    echo "import warnings" | tee ${CONF_DIR}/config.py; \
    echo "warnings.filterwarnings('ignore')" | tee -a ${CONF_DIR}/config.py; \
    echo "c.NotebookApp.token = u''" | tee -a ${CONF_DIR}/config.py

WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", \
    "--allow-root", "--ip=0.0.0.0", "--NotebookApp.token="]
