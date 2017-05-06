FROM alpine:latest

MAINTAINER Juliano Petronetto <juliano.petronetto@gmail.com>

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk update && apk upgrade \
	&& apk add --no-cache tini python3 libstdc++ openblas freetype wget ca-certificates \
	&& python3 -m ensurepip && rm -r /usr/lib/python*/ensurepip \
	&& pip3 install --upgrade pip setuptools \
	&& apk add --no-cache --virtual .build-deps@testing python3-dev make cmake clang clang-dev g++ linux-headers libtbb@testing libtbb-dev@testing openblas-dev freetype-dev \
	&& export CC=/usr/bin/clang CXX=/usr/bin/clang++ \
	&& ln -s /usr/include/locale.h /usr/include/xlocale.h \
	&& mkdir -p /opt/tmp && cd /opt/tmp \
	&& pip download -d /opt/tmp numpy \
	&& unzip -q numpy*.zip \
	&& cd numpy* && echo "Building numpy..." \
	&& echo -e "[ALL]\nlibrary_dirs = /usr/lib\ninclude_dirs = /usr/include\n[atlas]\natlas_libs = openblas\nlibraries = openblas\n[openblas]\nlibraries = openblas\nlibrary_dirs = /usr/lib\ninclude_dirs = /usr/include\n" > site.cfg \
	&& python3 setup.py build -j 4 install &> /dev/null && echo "Successfully installed numpy" \
	&& cd /opt/tmp \
	&& echo "Downloading opencv" && wget --quiet https://github.com/opencv/opencv/archive/3.2.0.zip \
	&& unzip -q 3.2.0.zip \
	&& cd opencv* \
	&& mkdir build && cd build && echo "Building opencv..." \
	&& cmake -D CMAKE_BUILD_TYPE=RELEASE \
		-D CMAKE_INSTALL_PREFIX=/usr \
		-D INSTALL_C_EXAMPLES=OFF \
		-D INSTALL_PYTHON_EXAMPLES=OFF \
		-D WITH_FFMPEG=NO \
		-D WITH_IPP=NO \
		-D WITH_OPENEXR=NO \
		-D WITH_WEBP=NO \
		-D WITH_TIFF=NO \
		-D WITH_JASPER=NO \
		-D BUILD_EXAMPLES=OFF \
		-D BUILD_PERF_TESTS=NO \
		-D BUILD_TESTS=NO .. &> /dev/null \
	&& make &> /dev/null && make install &> /dev/null && echo "Successfully installed opencv" \
	&& pip3 install --upgrade matplotlib jupyter ipywidgets \
	&& jupyter nbextension enable --py widgetsnbextension \
	&& cd /opt && rm -r /opt/tmp && mkdir -p /opt/notebook \
	&& unset CC CXX \
	&& apk del .build-deps \
	&& rm -r /root/.cache \
	&& find /usr/lib/python3.5/ -type d -name tests -depth -exec rm -rf {} \; \
	&& find /usr/lib/python3.5/ -type d -name test -depth -exec rm -rf {} \; \
	&& find /usr/lib/python3.5/ -name __pycache__ -depth -exec rm -rf {} \;

# Create nbuser user with UID=1000 and in the 'users' group
# Grant ownership over the conda dir and home dir, but stick the group as root.
RUN adduser -s /bin/bash -u 1000 -D nbuser && \
    mkdir /home/nbuser/work \
    && mkdir /home/nbuser/.jupyter \
    && mkdir /home/nbuser/.local \

USER nbuser

EXPOSE 8888
WORKDIR /opt/notebook
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]