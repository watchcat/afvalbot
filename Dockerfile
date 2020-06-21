FROM ubuntu:latest
WORKDIR /code
RUN apt-get update && apt-get -y upgrade \
  &&  apt-get -y install libssl-dev
#ENV FLASK_APP app.py
#ENV FLASK_RUN_HOST 0.0.0.0
#RUN apk add --no-cache gcc musl-dev linux-headers
COPY afvalbot afvalbot
COPY watchdog.sh
#RUN pip install -r requirements.txt
#COPY . .
CMD ["./watchdog.sh"]
