FROM jupyter/scipy-notebook:1386e2046833 as hadoop
LABEL maintainer="james.cross@colibridigital.io"
ENV HADOOP_VERSION 3.2.0
ENV HADOOP_HOME /usr/local/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
ENV HADOOP_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
USER root
RUN wget \
  --no-check-certificate --quiet \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" -O hadoop.tar.gz \
  && gunzip hadoop.tar.gz \
  && tar -C /usr/local/ -xf hadoop.tar \
  && rm hadoop.tar \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME \
  && mkdir -p /usr/local/hadoop-deps \
  && for i in $(echo $HADOOP_CLASSPATH | tr ":" "\n"); do cp $i /usr/local/hadoop-deps/ -r; done

# ----------------------------------------------------------------------JUPYTER NOTEBOOK----------------------------------------------------------------
FROM jupyter/scipy-notebook:1386e2046833
LABEL maintainer="james.cross@colibridigital.io"
ENV SPARK_VERSION 2.4.1
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /usr/local/spark-${SPARK_VERSION}
ENV PATH $PATH:$SPARK_HOME/bin
ENV HADOOP_VERSION 3.2.0
ENV HADOOP_HOME /usr/local/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
ENV SPARK_DIST_CLASSPATH="/usr/local/hadoop-deps/*"
ENV PATH $PATH:${SPARK_HOME}/bin
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:/opt/conda/lib/python3.7/site-packages
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
COPY --from=hadoop /usr/local/hadoop-deps/* /usr/local/hadoop-deps/
USER root
RUN wget \
  --no-check-certificate --quiet \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" -O spark.tar.gz \
  && gunzip spark.tar.gz \
  && tar -C /usr/local/ -xf spark.tar \
  && rm spark.tar \
  && mv /usr/local/$SPARK_PACKAGE $SPARK_HOME \
  && chown -R root:root $SPARK_HOME \
  && rm /usr/local/hadoop-deps/avro-1.7.7.jar \
  && wget https://repo1.maven.org/maven2/org/apache/avro/avro/1.8.2/avro-1.8.2.jar -P /usr/local/hadoop-deps/ \
  && wget https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.11/${SPARK_VERSION}/spark-avro_2.11-${SPARK_VERSION}.jar -P /usr/local/hadoop-deps/ \
  && apt-get -y update \
  && apt-get -y upgrade \
  && apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java ssh vim exuberant-ctags gcc g++ build-essential unixodbc-dev r-base libpq-dev python-dev \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------------PyArrow------------------------------------------------------------------------------------
RUN conda install --quiet -y 'pyarrow' && \
  conda clean -tipsy && \
  conda install --quiet -y pytorch torchvision -c pytorch && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER && \
  pip install --no-cache-dir -e $SPARK_HOME/python/

# ------------------------------------------------------------------------------------Install R Kernel------------------------------------------------------------------------------------
RUN conda install -c r r-irkernel

# ------------------------------------------------------------------------------------Install Julia Kernel------------------------------------------------------------------------------------
ADD ./install_ijulia.jl /tmp/install_ijulia
ENV JULIA_DEPOT_PATH=/opt/julia
RUN mkdir -p /opt/julia \
 && wget --no-check-certificate --quiet "https://julialang-s3.julialang.org/bin/linux/x64/1.2/julia-1.2.0-linux-x86_64.tar.gz" -O julia.tar.gz \
 && tar -C /opt -xvf julia.tar.gz \
 && ln -s /opt/julia-1.2.0/bin/julia /usr/bin/
RUN julia /tmp/install_ijulia
RUN chmod -R 777 .local/ \
  && chmod -R 777 /opt/julia/ \
  && rm julia.tar.gz \
  && fix-permissions /opt/julia/

# ------------------------------------------------------------------------------------Install Microsoft ODBC Driver 17 for SQL Server------------------------------------------------------------------------------------
RUN apt-get -y update \
  && apt-get install --no-install-recommends -y gnupg2 \
  && curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add \
  && apt-get -y update \
  && ACCEPT_EULA=Y apt-get install --no-install-recommends -y msodbcsql17 \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------------Useful linux commands------------------------------------------------------------------------------------
RUN apt-get -y update \
  && apt-get --no-install-recommends -y install nmon libpcap0.8 libpcap0.8-dev libncurses5 libncurses5-dev iftop emacs unoconv imagemagick mutt htop iozone3 cron \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------------R packages and dependencies------------------------------------------------------------------------------------
ADD ./packages.R ./
RUN export MAKE='make -j 8'
# RUN Rscript packages.R

# # ------------------------------------------------------------------------------------Python packages and dependencies------------------------------------------------------------------------------------
# ADD ./requirements.txt ./
# RUN pip --no-cache-dir install -r requirements.txt