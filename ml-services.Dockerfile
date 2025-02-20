FROM python:3.12-bookworm as builder

RUN pip install poetry==1.8.5

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /ml-services
COPY pyproject.toml .
COPY poetry.lock .
COPY poetry.toml .

RUN poetry install --no-root && rm -rf $POETRY_CACHE_DIR

FROM python:3.12-slim-bookworm as runtime

ENV VIRTUAL_ENV=/ml-services/.venv \
    PATH="/ml-services/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY scripts '/ml-services/scripts'

WORKDIR /ml-services

EXPOSE 8080

CMD ["python", "scripts/torch_service.py"]

