FROM python:3.12.2-slim AS final

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip3 install --disable-pip-version-check -r requirements.txt

COPY . /app

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1
# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["python3", "worker.py"]
