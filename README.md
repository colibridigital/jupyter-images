[![CircleCI](https://circleci.com/gh/colibridigital/jupyter-images.svg?style=svg)](https://circleci.com/gh/colibridigital/jupyter-images)

# Jupyter Images
A collection of useful, fully featured images that builds on the great work by the Jupyter team by adding additional handy features.

* For the standard datascience notebook image: `docker pull colibridigital/jupyter-datascience-notebook`
* For the GPU notebook image: `colibridigital/jupyter-datascience-notebook:gpu`

## Jupyter Datascience Notebook
A fully featured data science image, based on the Jupyter Scipy Notebook image.  Adds the following:
* Spark 2.4.1
* Hadoop 3.2.0
* Pyarrow
* ODBC Driver 17
* R kernel
* Julia kernel
* Lots of useful R and Jupyter packages
* Some handy terminal commands like htop, cron, nmon, iftop, and libpcap

## Jupyter Datascience GPU Notebook
The same as the Jupyter Datascience Notebook image, but with added CUDA!  This image is based on tensorflow/tensorflow:latest-gpu.  This image is available by adding the `gpu` tag

