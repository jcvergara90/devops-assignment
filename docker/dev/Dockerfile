FROM python:3.8-alpine

RUN apk update && \
    apk upgrade && \
    apk add build-base

RUN mkdir /app
ONBUILD ADD . /app/
WORKDIR /app
ADD requirements.txt /app/requirements.txt

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
