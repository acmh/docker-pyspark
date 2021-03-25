# docker-pyspark
Docker image based on godatadriven/pyspark but with improvements

## Tech Specs
PySpark docker container based on OpenJDK and Miniconda 3.

The main difference from the godatadriven/pyspark image is that you can change the following arguments:

```
MINICONDA_VERSION=3
MINICONDA_RELEASE=py38_4.9.2
PYTHON_VERSION=3.8
HADOOP_VERSION=3.2.0
SPARK_VERSION=3.1.1
SPARK_EXTRAS=
```

### Warning when modifying spark and hadoop versions
Spark version library are pre-packaged for a specific Hadoop version.
This image uses Spark 3.1.1 and consequently needs the Hadoop 3.2.0 version, you can look this in https://spark.apache.org/releases/spark-release-3-1-1.html. The versions of Hadoop and hadoop-aws should be the same, so this image uses the https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-aws/3.2.0 version and you
must guarantee the hadoop-aws is compatible with aws-java-sdk-bundle version, in this
case https://mvnrepository.com/artifact/com.amazonaws/aws-java-sdk-bundle/1.11.375.
You should look the hadoop-aws compatible dependencies versions in
https://hadoop.apache.org/docs/r3.2.0/hadoop-aws/dependency-analysis.html.

## Building the imamge
```bash
docker build -t IMAGE_NAME .
```

## Running the container

```bash
docker run -v /local_folder:/job IMAGE_NAME spark-submit [options] /job/<python file> [app arguments]
```

## Credits
Thanks for all the contributors of godatadriven/pyspark.

https://github.com/godatadriven-dockerhub/pyspark
