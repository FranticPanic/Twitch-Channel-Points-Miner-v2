FROM python:3.10-slim-bookworm

ARG BUILDX_QEMU_ENV

LABEL org.opencontainers.image.source="https://github.com/FranticPanic/Twitch-Channel-Points-Miner-v2" \
      org.opencontainers.image.description="Docker image for the Twitch Channel Points Miner Armi1014 fork" \
      org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /usr/src/app

COPY requirements.txt pyproject.toml setup.py README.md ./
COPY TwitchChannelPointsMiner ./TwitchChannelPointsMiner

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --fix-missing --no-install-recommends \
        automake \
        cmake \
        g++ \
        gcc \
        libblas-dev \
        libffi-dev \
        libjpeg-dev \
        liblapack-dev \
        libssl-dev \
        make \
        ninja-build \
        python3-dev \
        rustc \
        subversion \
        zlib1g-dev \
    && if [ "${BUILDX_QEMU_ENV}" = "true" ] && [ "$(getconf LONG_BIT)" = "32" ]; then \
        pip install --upgrade cryptography==3.3.2; \
       fi \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && apt-get remove -y gcc rustc \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc/*

# The image is runnable on its own. Compose replaces this starter configuration
# with the user's ignored run.py through a read-only bind mount.
COPY example.py ./run.py

RUN mkdir -p analytics cookies logs

ENTRYPOINT ["python", "run.py"]
