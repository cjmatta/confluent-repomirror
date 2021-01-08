#!/bin/bash
# This is a bash script to simplify the creation, execution of a docker container 
# that downloads a mirror of the specified Confluent Platform 

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PACKAGE=$(basename -- $0)
CLEANUP=true
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "${PACKAGE} - download the Confluent Platform RPMs using Yum reposync on a Docker container"
      echo ""
      echo "${PACKAGE} [options]"
      echo "options:"
      echo "-h, --help      show help"
      echo "-v              Confluent version, defaults to 6.0"
      echo "-d              Directory to download the repository to, defaults to ./confluent-<version>"
      echo "--no-cleanup    Don't remove the created docker image, by default this script cleans up after itself"
      echo ""
      exit 0
      ;;
    -v)
      shift
      if test $# -gt 0; then
        export CP_VERSION=$1
      else
        echo "No version specified!"
        exit 1
      fi
      shift
      ;;
    -d)
      shift
      if test $# -gt 0; then
        export DOWNLOAD_DIR=$1
      else
        echo "No download directory specified!"
        exit 1
      fi
      shift
      ;;
    --no-cleanup)
      shift
      export CLEANUP=false
      shift
      ;;
    *)
      break
      ;;
  esac
done


if [[ ! -f ${DIR}/Dockerfile ]]; then
    echo "Error: can't find Dockerfile!"
    exit 1
fi

docker=$(which docker)
if [[ ! -x "${docker}" ]]; then
    echo "Error: Can't find docker on this user's path!"
    exit 1
fi

if [[ "x${CP_VERSION}" == "x" ]]; then
    CP_VERSION=6.0
fi

if [[ "x${DOWNLOAD_DIR}" == "x" ]]; then
    DOWNLOAD_DIR="${DIR}/confluent-${CP_VERSION}"
fi

# Determine if the specified path is absolute or not
# so we can provide the canonical path that Docker requires
case ${DOWNLOAD_DIR} in
    /*) ;;
    ./*) export DOWNLOAD_DIR=${DIR}/$(basename -- ${DOWNLOAD_DIR});;
    *) export DOWNLOAD_DIR=${DIR}/${DOWNLOAD_DIR} ;;
esac


DOCKER_CONTAINER_NAME=confluent-reposync

# DEBUG
# echo "CP_VERSION: ${CP_VERSION}"
# echo "DOWNLOAD_DIR: ${DOWNLOAD_DIR}"
# echo "CLEANUP: ${CLEANUP}"
#  exit 1

# BUILD
${docker} build --build-arg CONFLUENT_VERSION=${CP_VERSION} -t ${DOCKER_CONTAINER_NAME} ${DIR} && \
# RUN
${docker} run --rm -v ${DOWNLOAD_DIR}:/repodir ${DOCKER_CONTAINER_NAME}

if [[ ${CLEANUP} = true ]]; then
    echo "Cleaning up...."
    ${docker} rmi ${DOCKER_CONTAINER_NAME}
fi
