FROM python:3.12.0a5-alpine3.17
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
EXPOSE 8080
