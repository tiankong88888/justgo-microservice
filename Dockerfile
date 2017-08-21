FROM golang:1.8-alpine3.6
MAINTAINER Irakli Nadareishvili

ENV PORT=3737
# Commented-out because these are defaults anyway
# ENV GOPATH=/go
# ENV PATH=${GOPATH}/bin:${PATH}
ENV APP_USER=appuser
ENV SRC_PATH=/home/app
ENV APP_ENV=production

COPY . ${SRC_PATH}
WORKDIR ${SRC_PATH}

USER root

RUN adduser -s /bin/false -D ${APP_USER} \
 && echo "Installing git and ssh support" \ 
 && apk update && apk upgrade \
 && apk add --no-cache bash git openssh \
 && echo "Installing infrastructural go packages…" \
 && go get -u github.com/githubnemo/CompileDaemon \
 && go get -u github.com/golang/dep/cmd/dep \
 && echo "Building project…" \
 && ${SRC_PATH}/go-wrapper env \ 
 && export goDir="$(go list -e -f '{{.ImportComment}}' 2>/dev/null || true)" \
 && cd "${GOPATH}/src/${goDir}" \
 && ${SRC_PATH}/go-wrapper dep \
 && go-wrapper install \
 && echo "Fixing permissions..." \
 && chown -R ${APP_USER} ${GOPATH} \
 && chown -R ${APP_USER} ${SRC_PATH} \
 && echo "Cleaning up installation caches to reduce image size" \
 && rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/* 

USER ${APP_USER}

EXPOSE 3737

CMD ["go-wrapper", "run"]
