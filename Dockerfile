FROM ubuntu:latest as STAGEONE

# install hugo
ENV HUGO_VERSION=0.93.2
ARG HUGO_ARCH="64bit"

ENV HUGO_ARCH=${HUGO_ARCH}

ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz /tmp/
RUN tar -xf /tmp/hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz -C /usr/local/bin/

# install syntax highlighting
RUN apt-get update
RUN apt-get install -y python3-pygments

# build site
COPY source /source
RUN hugo --source=/source/ --destination=/public/

FROM nginx:stable-alpine as PRODUCTION
RUN apk --update add curl bash
COPY --from=STAGEONE /public/ /usr/share/nginx/html/
EXPOSE 80 443