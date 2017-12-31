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

FROM alpine:3.6

LABEL maintainer="Juliano Petronetto <juliano@petronetto.com.br>" \
      name="Machine Learning Alpine" \
      description="Almosto anything that you need for machine learning in a small container." \
      url="https://hub.docker.com/r/petronetto/machine-learning-alpine" \
      vcs-url="https://github.com/petronetto/machine-learning-alpine" \
      vendor="Petronetto DevTech" \
      version="1.0"

RUN echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
    echo "http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
    echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
    echo "http://dl-5.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies for Python are installed later
RUN apk add --no-cache ca-certificates

# Setup de basic requeriments
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 --no-cache-dir install --upgrade pip setuptools

# Dev dependencies and others stuffs...
RUN apk add --no-cache tini libstdc++ gcc freetype \
        zlib jpeg libpng graphviz font-noto && \
    apk add --no-cache \
        --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        lapack-dev && \
    apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran musl-dev pkgconfig freetype-dev \
        jpeg-dev zlib-dev libpng-dev make \
        python3-dev libc-dev && \
    ln -s locale.h /usr/include/xlocale.h

# Python packages
RUN pip --no-cache-dir install -U 'pip'  && \
    pip --no-cache-dir install 'cython' && \
    pip --no-cache-dir install 'numpy' && \
    pip --no-cache-dir install 'scipy' && \
    pip --no-cache-dir install 'pandas' && \
    pip --no-cache-dir install 'scikit-learn' && \
    pip --no-cache-dir install 'matplotlib' && \
    pip --no-cache-dir install 'seaborn' && \
    pip --no-cache-dir install 'xgboost' && \
    pip --no-cache-dir install 'jupyter'

# Cleaning
RUN pip uninstall --yes cython && \
    rm /usr/include/xlocale.h && \
    rm -rf /root/.cache && \
    rm -rf /var/cache/apk/* && \
    apk del .build-dependencies && \
    mkdir -p /root/.jupyter

# Run notebook without token and disable warnings
RUN echo " \n\
import warnings \n\
warnings.filterwarnings('ignore') \n\
c.NotebookApp.token = u''" >> /root/.jupyter/config.py

EXPOSE 8888

WORKDIR /notebooks

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--allow-root", "--ip=0.0.0.0", "--NotebookApp.token="]
