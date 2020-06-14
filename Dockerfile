From alpine
WORKDIR /code
#ENV FLASK_APP app.py
#ENV FLASK_RUN_HOST 0.0.0.0
#RUN apk add --no-cache gcc musl-dev linux-headers
COPY afvalbot afvalbot
#RUN pip install -r requirements.txt
#COPY . .
CMD ["afvalbot"]
