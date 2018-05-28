# Alpine Container for Machine Learning

```
  __  __            _     _              _                          _
 |  \/  | __ _  ___| |__ (_)_ __   ___  | |    ___  __ _ _ __ _ __ (_)_ __   __ _
 | |\/| |/ _` |/ __| '_ \| | '_ \ / _ \ | |   / _ \/ _` | '__| '_ \| | '_ \ / _` |
 | |  | | (_| | (__| | | | | | | |  __/ | |__|  __/ (_| | |  | | | | | | | | (_| |
 |_|  |_|\__,_|\___|_| |_|_|_| |_|\___| |_____\___|\__,_|_|  |_| |_|_|_| |_|\__, |
                                                                            |___/
```
[![petronetto/machine-learning-alpine](http://dockeri.co/image/petronetto/machine-learning-alpine)](https://registry.hub.docker.com/u/petronetto/machine-learning-alpine/)

[![](https://images.microbadger.com/badges/image/petronetto/machine-learning-alpine.svg)](https://microbadger.com/images/petronetto/machine-learning-alpine "Get your own image badge on microbadger.com")
[![GitHub issues](https://img.shields.io/github/issues/petronetto/machine-learning-alpine.svg)](https://github.com/petronetto/machine-learning-alpine/issues)
[![GitHub license](https://img.shields.io/github/license/petronetto/machine-learning-alpine.svg)](https://raw.githubusercontent.com/petronetto/machine-learning-alpine/master/LICENSE)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/petronetto/machine-learning-alpine.svg?style=social)](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2Fpetronetto%2Fmachine-learning-alpine)
[![CircleCI](https://circleci.com/gh/petronetto/machine-learning-alpine/tree/master.svg?style=svg)](https://circleci.com/gh/petronetto/machine-learning-alpine/tree/master)

## What is include
- Python 3.6
- NumPy
- SciPy
- Scikit-learn
- Pandas
- Matplotlib
- Seaborn
- XGBoost
- Jupyter Notebook

All in a small container around 150 MB :)


## Running the container
- Clone this repository: `git clone git@github.com:petronetto/machine-learning-alpine.git`

- Enter in project folder: `cd machine-learning-alpine`

- Run: `docker-composer up` and open your browser in `http://localhost:8888`

See the `Welcome.ipynb` to see the package versions.

or

```
docker run -it --name machine-learning \
           -v $(PWD):/notebooks \
           -p 8888:8888 -d \
           petronetto/machine-learning-alpine
```


> If you want work with TensorFlow, you can see my other containers: https://github.com/petronetto/tensorflow-alpine

Enjoy :)

License: [BSD 3-Clause](LICENSE)


<a href='https://ko-fi.com/N4N09BMZ' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
