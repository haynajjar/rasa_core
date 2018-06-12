FROM python:2.7-slim


# Run updates, install basics and cleanup
# - build-essential: Compile specific dependencies
# - git-core: Checkout git repos
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential git-core openssl libssl-dev libffi6 libffi-dev curl  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



#ENV PATH=/root/.local/bin:$PATH

#RUN apt-get update -y && apt-get install -y swig
#RUN curl -sSL https://get.haskellstack.org/ | sh
#RUN stack setup
#COPY . /pyduckling
#WORKDIR /pyduckling/pyduckling
#RUN stack new .
#RUN stack build
#RUN stack ghc -- -c -dynamic -fPIC DucklingFFI.hs
#RUN swig -python pyduckling.i
#RUN gcc -fpic -c pyduckling.c pyduckling_wrap.c `python3.5-config --includes` -I`stack ghc -- --print-libdir`/include
#RUN stack ghc --package duckling -- -o _pyduckling.so -shared -dynamic -fPIC pyduckling.o pyduckling_wrap.o DucklingFFI.o -lHSrts-ghc8.0.2
#WORKDIR /pyduckling
#RUN pip install pytest python-dateutil


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
    

RUN python -m spacy download en
RUN python -m spacy download fr

## rasa core
RUN pip install rasa_core

# volumes
VOLUME ["/app/logs", "/app/data", "/app/config"]


EXPOSE 5000

ENTRYPOINT ["./entrypoint.sh"]
