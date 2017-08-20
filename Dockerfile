# MIT License

# Copyright (c) 2017 Juliano Petronetto

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM alpine:3.5

MAINTAINER Juliano Petronetto <juliano.petronetto@gmail.com>

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
RUN apk add --no-cache tini libstdc++ gcc freetype zlib jpeg libpng graphviz && \
    apk add --no-cache \
        --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        lapack-dev && \
    apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran musl-dev pkgconfig freetype-dev jpeg-dev zlib-dev libpng-dev make \
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
