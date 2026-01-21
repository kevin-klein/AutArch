FROM python:3.12-bookworm as builder

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /ml-services
COPY ./requirements.txt .

RUN pip install -Ur requirements.txt

FROM python:3.12-slim-bookworm as runtime

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY scripts '/ml-services/scripts'

WORKDIR /ml-services

EXPOSE 8080

CMD ["python", "scripts/torch_service.py"]

