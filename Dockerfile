FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES git build-base
# ENV GOPROXY https://mirrors.aliyun.com/goproxy/


ENV GOPATH /root/go
ENV REPO_PATH $GOPATH/src/github.com/halleproject/hallechain
ENV GO111MODULE on
# ENV  GONOSUMDB="github.com/cosmos/cosmos-sdk"
# ENV  GOSUMDB="off"
COPY . $REPO_PATH/
WORKDIR $REPO_PATH

RUN mkdir -p $REPO_PATH/build && apk add --no-cache $PACKAGES   && make build


# Final image
FROM alpine

ENV GOPATH /root/go
ENV REPO_PATH $GOPATH/src/github.com/halleproject/hallechain

WORKDIR /usr/bin/

COPY --from=build-env $REPO_PATH/build/halled /usr/bin/halled
COPY --from=build-env $REPO_PATH/build/hallecli /usr/bin/hallecli

# Run halled by default
CMD ["halled","start","--minimum-gas-prices","5.0uhale","--pruning=nothing","--log_level","main:info,state:info,mempool:info"]
