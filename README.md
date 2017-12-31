# Alpine Container for Machine Learning

```
  __  __            _     _              _                          _
 |  \/  | __ _  ___| |__ (_)_ __   ___  | |    ___  __ _ _ __ _ __ (_)_ __   __ _
 | |\/| |/ _` |/ __| '_ \| | '_ \ / _ \ | |   / _ \/ _` | '__| '_ \| | '_ \ / _` |
 | |  | | (_| | (__| | | | | | | |  __/ | |__|  __/ (_| | |  | | | | | | | | (_| |
 |_|  |_|\__,_|\___|_| |_|_|_| |_|\___| |_____\___|\__,_|_|  |_| |_|_|_| |_|\__, |
                                                                            |___/
```

[![](https://images.microbadger.com/badges/image/petronetto/machine-learning-alpine.svg)](https://microbadger.com/images/petronetto/machine-learning-alpine "Get your own image badge on microbadger.com")
[![GitHub issues](https://img.shields.io/github/issues/Petronetto/machine-learning-alpine.svg)](https://github.com/Petronetto/machine-learning-alpine/issues)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Petronetto/machine-learning-alpine/master/License.txt)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/Petronetto/machine-learning-alpine.svg?style=social)](https://twitter.com/intent/tweet?text=Wow:&url=%5Bobject%20Object%5D)

## What is include
- Python 3.5
- NumPy
- SciPy
- Scikit-learn
- Pandas
- Matplotlib
- Seaborn
- XGBoost
- Jupyter Notebook

All in only ~200 MB :)


## Running the container
- Clone this repository: `git clone git@github.com:Petronetto/machine-learning-alpine.git`

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
