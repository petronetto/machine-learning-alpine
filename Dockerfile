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

FROM alpine:3.6

LABEL maintainer="Juliano Petronetto <juliano@petronetto.com.br>"
LABEL org.label-schema.name="Machine Learning Alpine" \
      org.label-schema.description="Basic tools to work with machine learning in Python, using a small Alpine container" \
      org.label-schema.url="https://hub.docker.com/r/petronetto/machine-learning-alpine" \
      org.label-schema.vcs-url="https://github.com/petronetto/machine-learning-alpine" \
      org.label-schema.vendor="Petronetto DevTech" \
      org.label-schema.version="1.5" \
      org.label-schema.schema-version="1.0"

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories \
    && apk add --update --no-cache python3 \
        tini libstdc++ gcc freetype zlib curl openblas \
        jpeg libpng graphviz lapack ca-certificates \
## Setup de basic requeriments
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 --no-cache-dir install --upgrade pip setuptools \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi \
    && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
## Dev dependencies and others stuffs...
    && apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran build-base musl-dev pkgconfig freetype-dev jpeg-dev \
        openblas-dev zlib-dev libpng-dev make python3-dev linux-headers \
        libc-dev cython-dev gfortran wget \
    && ln -s locale.h /usr/include/xlocale.h \
## Python packages
    && pip install --no-cache-dir -U numpy \
    && pip install --no-cache-dir -U scipy \
    && pip install --no-cache-dir -U pandas \
    && pip install --no-cache-dir -U scikit-learn \
    && pip install --no-cache-dir -U matplotlib \
    && pip install --no-cache-dir -U seaborn \
    && pip install --no-cache-dir -U xgboost \
    && pip install --no-cache-dir -U jupyter \
## Cleaning
    && rm /usr/include/xlocale.h \
    && rm -rf /root/.cache \
    && rm -rf /var/cache/apk/* \
    && apk del .build-dependencies \
    && find /usr/lib/python3.6 -name __pycache__ | xargs rm -r \
    && rm -rf /root/.[acpw]* \
## Run notebook without token and disable warnings
    && mkdir -p /root/.jupyter \
    && echo "import warnings" >> /root/.jupyter/config.py \
    && echo "warnings.filterwarnings('ignore')" >> /root/.jupyter/config.py \
    && echo "c.NotebookApp.token = u''" >> /root/.jupyter/config.py

EXPOSE 8888

WORKDIR /notebooks

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--allow-root", "--ip=0.0.0.0", "--NotebookApp.token="]
