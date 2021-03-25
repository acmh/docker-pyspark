ARG OPENJDK_VERSION=8
FROM openjdk:${OPENJDK_VERSION}-jre-slim

# Warning:
# Spark version library are pre-packaged for a specific Hadoop version.
# This image uses Spark 3.1.1 and consequently needs the Hadoop 3.2.0 version,
# you can look this in https://spark.apache.org/releases/spark-release-3-1-1.html.
# The versions of Hadoop and hadoop-aws should be the same, so this image uses the
# https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-aws/3.2.0 version and you
# must guarantee the hadoop-aws is compatible with aws-java-sdk-bundle version, in this
# case https://mvnrepository.com/artifact/com.amazonaws/aws-java-sdk-bundle/1.11.375.
# You should look the hadoop-aws compatible dependencies versions in
# https://hadoop.apache.org/docs/r3.2.0/hadoop-aws/dependency-analysis.html.

ARG MINICONDA_VERSION=3
ARG MINICONDA_RELEASE=py38_4.9.2
ARG PYTHON_VERSION=3.8
ARG HADOOP_VERSION=3.2.0
ARG SPARK_VERSION=3.1.1
ARG SPARK_EXTRAS=

LABEL org.opencontainers.image.title="Apache PySpark $SPARK_VERSION" \
      org.opencontainers.image.version=$SPARK_VERSION

ENV MINICONDA_HOME="/opt/miniconda${MINICONDA_VERSION}"
ENV HADOOP_VERSION="${HADOOP_VERSION}"
ENV HADOOP_HOME="/usr/local/hadoop/hadoop-${HADOOP_VERSION}"
ENV SPARK_VERSION="${SPARK_VERSION}"
ENV PYSPARK_PYTHON="${MINICONDA_HOME}/bin/python"
ENV PATH="${MINICONDA_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH="$HADOOP_HOME/lib/native"

# Install basic dependencies
RUN set -ex && \
	apt-get update && \
    apt-get install -y curl bzip2 --no-install-recommends

# Install Miniconda
RUN set -ex && \
    curl -s -L --url "https://repo.continuum.io/miniconda/Miniconda${MINICONDA_VERSION}-${MINICONDA_RELEASE}-Linux-x86_64.sh" --output /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -f -p "${MINICONDA_HOME}" && \
    rm /tmp/miniconda.sh && \
    conda clean -tipy && \
    echo "PATH=${MINICONDA_HOME}/bin:\${PATH}" > /etc/profile.d/miniconda.sh

# Install pyspark
RUN set -ex && \
    pip install --no-cache pyspark[$SPARK_EXTRAS]==${SPARK_VERSION}

# Install hadoop common
RUN set -ex && \
    curl -s -L --url "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" --output /tmp/hadoop-${HADOOP_VERSION}.tar.gz && \
    mkdir -p ${HADOOP_HOME} && \
    tar -xzf /tmp/hadoop-${HADOOP_VERSION}.tar.gz -C /usr/local/hadoop

# Create spark profile
RUN set -ex && \
    echo "#!/bin/bash" > /etc/profile.d/spark.sh && \
    echo "export SPARK_HOME=$(python ${MINICONDA_HOME}/bin/find_spark_home.py)" >> /etc/profile.d/spark.sh && \
    echo "export SPARK_DIST_CLASSPATH=$(hadoop classpath):${HADOOP_HOME}/share/hadoop/tools/lib/*" >> /etc/profile.d/spark.sh && \
    chmod +x /etc/profile.d/spark.sh

# Clean up
RUN set -ex && \
    apt-get remove -y curl bzip2 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /tmp/*

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]