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
# SOFTWARE

FROM petronetto/miniconda-alpine

MAINTAINER Juliano Petronetto <juliano.petronetto@gmail.com>

# Create nbuser user with UID=1000 and in the 'users' group
RUN adduser -G users -u 1000 -s /bin/sh -D nbuser && \
    echo "nbuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /home/nbuser/notebooks && \
    mkdir /home/nbuser/.jupyter && \
    mkdir /home/nbuser/.local && \
    chown -Rf nbuser:users /home/nbuser

RUN conda install -y scikit-learn pandas matplotlib seaborn jupyter

# Run notebook without token and disable warnings
RUN echo " \n\
import warnings \n\
warnings.filterwarnings('ignore') \n\
c.NotebookApp.token = u''" >> /home/nbuser/.jupyter/jupyter_notebook_config.py

RUN conda install -c conda-forge xgboost python=3.5 --yes && \
    conda install -c conda-forge keras python=3.5 --yes && \
    conda clean --yes --all

EXPOSE 8888

USER nbuser

WORKDIR /home/nbuser/notebooks

CMD ["/opt/conda/bin/jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token="]