# ref: https://github.com/mamba-org/micromamba-docker/blob/main/Dockerfile

FROM condaforge/mambaforge:latest

ARG ENV=base

LABEL maintainer="Ivan Ogasawara <ivan.ogasawara@gmail.com>"
LABEL org.opencontainers.image.title="LiteRev"
LABEL org.opencontainers.image.authors="LiteRev Team"
LABEL org.opencontainers.image.source="https://github.com/thegraphnetwork-literev/literev-legal-deps"
LABEL org.opencontainers.image.version="${ENV}"
LABEL org.opencontainers.image.description="LiteRev Web"
LABEL org.mentalhealthai_org.config.version="${ENV}"

# it is the default, but using it here to have it explicitly
USER root

SHELL ["/bin/bash", "-c"]
# Use bash in Dockerfile RUN commands and make sure bashrc is sourced when
# executing commands with /bin/bash -c
# Needed to have the micromamba activate command configured etc.

ENV ENV_NAME=literev-legal
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ARG UID=1000
ARG GID=1000

RUN apt-get update -y \
  && apt-get install -y \
    apt-utils \
    build-essential \
    curl \
    tini \
    nginx \
    snapd \
    sudo \
    tzdata \
    gcc-multilib \
    g++-multilib \
    openssl \
  && rm -rf /var/lib/apt/lists/* \
    /var/cache/apt/archives \
    /tmp/*

ENV USERNAME=mhai

RUN addgroup --gid ${GID} ${USERNAME} \
  && useradd --uid ${UID} --gid ${GID} -ms /bin/bash ${USERNAME} \
  && mkdir -p /opt/deps \
	&& mkdir -p /opt/services \
	&& chmod -R a+rwx /opt/conda /opt/services /opt/deps \
  && export ENV_NAME="$ENV_NAME" \
  && chown -R ${USERNAME}:${USERNAME} /opt/ \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} ./conda/ /opt/deps

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN mamba env create -n $ENV_NAME --file /opt/deps/${ENV}.yaml \
  && conda clean --all \
  && find /opt/conda/ -type f,l -name '*.pyc' -delete \
  && find /opt/conda/ -type f,l -name '*.js.map' -delete \
  && rm -rf /opt/conda/pkgs /tmp/*

ENV CONDA_PREFIX /opt/conda/envs/$ENV_NAME
ENV PATH ${CONDA_PREFIX}/bin:$PATH
ENV ENV=${ENV}

# install dependencies
COPY --chown=${USERNAME}:${USERNAME} pyproject.toml poetry.lock /opt/deps/
COPY --chown=${USERNAME}:${USERNAME} containers/scripts/install-deps.sh /opt/deps/install-deps.sh
COPY --chown=${USERNAME}:${USERNAME} containers/scripts/activate.sh /opt/activate.sh

RUN conda init bash \
  && source ~/.bashrc \
  && source /opt/activate.sh \
  && conda env list \
  && /opt/deps/install-deps.sh

RUN sudo chown ${USERNAME}:${USERNAME} /opt/
COPY --chown=literev-legal:literev-legal ./containers/scripts/entrypoint.sh /opt/entrypoint.sh
RUN sudo sed -i 's/\r$//g' /opt/entrypoint.sh \
  && sudo chmod +x /opt/entrypoint.sh

ENTRYPOINT ["tini", "--", "/opt/entrypoint.sh"]
