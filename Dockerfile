FROM ubuntu:latest
WORKDIR /code
RUN apt-get update && apt-get -y upgrade \
  &&  apt-get -y install libssl-dev

COPY afvalbot afvalbot
COPY watchdog.sh watchdog.sh

CMD ["./watchdog.sh"]
