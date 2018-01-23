FROM python:2.7-slim

# Run updates, install basics and cleanup
# - build-essential: Compile specific dependencies
# - git-core: Checkout git repos
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential git-core openssl libssl-dev libffi6 libffi-dev curl  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# use bash always
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# workdir
WORKDIR /app
COPY . /app

# rasa stack
## rasa nlu
RUN pip install -r requirements/requirements_docker.txt
## spacy models
RUN pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-1.2.0/en_core_web_sm-1.2.0.tar.gz --no-cache-dir > /dev/null \
    && python -m spacy link en_core_web_sm en
    
## tensorflow
RUN pip install --upgrade "https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.4.1-cp27-none-linux_x86_64.whl"


## rasa core
RUN pip install rasa_core

# volumes
VOLUME ["/app/logs", "/app/data", "/app/config"]


EXPOSE 5000

ENTRYPOINT ["./entrypoint.sh"]
