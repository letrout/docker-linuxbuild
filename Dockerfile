FROM debian:9.4-slim
LABEL maintainer="Joel Luth (joelluth@gmail.com)"
LABEL description="Test filesystem performance with kernel untar/build"

RUN apt-get update      \
 && apt-get -y -q install \
        bc \
        bison   \
        build-essential \
        flex    \
        libelf-dev \
        libssl-dev \
        wget    \
 && apt-get clean \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

#ENV LINUX_VER=4.16.1
#ENV LINUX_DIR=/kernel \
#    LINUX_TARBALL=linux-${LINUX_VER}.tar.xz
#ENV LINUX_SRC_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/${LINUX_TARBALL}

#RUN mkdir -p ${LINUX_DIR} \
# && wget ${LINUX_SRC_URL} -O ${LINUX_DIR}/${LINUX_TARBALL}

#WORKDIR ${LINUX_DIR}
#RUN tar -xf ${LINUX_TARBALL}

COPY build_src.sh /
RUN chmod +x /build_src.sh
ENTRYPOINT /build_src.sh && /bin/bash