ARG NODE_VERSION=8.15.0-slim
FROM node:${NODE_VERSION}
ARG GITHUB_ACCOUNT=Atos-Research-and-Innovation
ARG GITHUB_REPOSITORY=IoTagent-LoRaWAN
ARG DOWNLOAD=latest

# Copying Build time arguments to environment variables so they are persisted at run time and can be
# inspected within a running container.
# see: https://vsupalov.com/docker-build-time-env-values/  for a deeper explanation.

ENV GITHUB_ACCOUNT=${GITHUB_ACCOUNT}
ENV GITHUB_REPOSITORY=${GITHUB_REPOSITORY}
ENV DOWNLOAD=${DOWNLOAD}

MAINTAINER FIWARE IoTAgent Team. Atos Spain S.A

#
# The following RUN command retrieves the source code from GitHub.
#
# To obtain the latest stable release run this Docker file with the parameters
# --no-cache --build-arg DOWNLOAD=stable
# To obtain any speciifc version of a release run this Docker file with the parameters
# --no-cache --build-arg DOWNLOAD=1.7.0
#
# The default download is the latest tip of the master of the named repository on GitHub
#
# Alternatively for local development, just copy this Dockerfile into file the root of the repository and
# replace the whole RUN statement by the following COPY statement in your local source using :
#
# COPY . /opt/iotagent-lora/
#
COPY . /opt/iotagent-lora/

WORKDIR /opt/iotagent-lora

RUN \
	# Ensure that Git is installed prior to running npm install
	apt-get update && \
	apt-get install -y git  && \
	npm install pm2@3.2.2 -g && \
	echo "INFO: npm install --production..." && \
	npm install --production && \
	# Remove Git and clean apt cache
	apt-get clean && \
	apt-get remove -y git && \
	apt-get -y autoremove

USER node
ENV NODE_ENV=production

ENTRYPOINT ["pm2-runtime", "bin/iotagent-lora"]
CMD ["-- ", "config.js"]
