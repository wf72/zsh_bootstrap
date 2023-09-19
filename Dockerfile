FROM centos:centos7
WORKDIR /app
COPY . ./

RUN bash ./zsh-bootstrap.sh