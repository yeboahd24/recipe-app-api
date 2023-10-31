FROM python:3.9-alpine3.13

LABEL maintainer="Dominic Yeboah <yeboahd24@gmail.com>"
LABEL version="1.0"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./scripts /scripts
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

# Install build dependencies
RUN apk add --update --no-cache \
        build-base \
        postgresql-dev \
        jpeg-dev \
        zlib-dev \
        musl-dev \
        linux-headers \
        gcc

# Create virtual environment and install dependencies
RUN python -m venv /py \
    && /py/bin/pip install --upgrade pip \
    && /py/bin/pip install -r /tmp/requirements.txt \
    && if [ $DEV = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi

# Remove build dependencies and clean up
RUN apk del build-base postgresql-dev jpeg-dev zlib-dev musl-dev linux-headers gcc \
    && rm -rf /tmp

# Create Django user and set directory permissions
RUN adduser \
        --disabled-password \
        --no-create-home \
        django-user \
    && mkdir -p /vol/web/media \
    && mkdir -p /vol/web/static \
    && chown -R django-user:django-user /vol \
    && chmod -R 755 /vol \
    && chmod -R +x /scripts

ENV PATH="/scripts/py/bin:$PATH"

# Switch to the Django user and execute the command
USER django-user
CMD ["run.sh"]
