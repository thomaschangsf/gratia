FROM python:3.7
#https://stackoverflow.com/questions/53835198/integrating-python-poetry-with-docker
WORKDIR /app
#&& poetry config settings.virtualenvs.create false \

COPY poetry.lock pyproject.toml ./
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir poetry \
 \
 && poetry install --no-dev \
 \
 && pip uninstall --yes poetry \

COPY . ./
