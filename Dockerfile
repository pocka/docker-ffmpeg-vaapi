# https://trac.ffmpeg.org/wiki/CompilationGuide/Centos

FROM centos
MAINTAINER SuperFlyXXI <superflyxxi@yahoo.com>

CMD ["--help"]
ENTRYPOINT ["ffmpeg"]

ARG SRC_DIR=/work
ARG PREFIX=/usr
ARG LIBDIR=/usr/lib64
ARG PKG_CONFIG_PATH=/usr/lib/pkgconfig

WORKDIR ${SRC_DIR}
RUN mkdir -p ${SRC_DIR}/build ${SRC_DIR}/bin

# Enable repos
RUN yum install -y --enablerepo=extras epel-release yum-utils && yum clean all

# Upgrade OS
RUN yum upgrade -y && yum clean all

# Install libdrm
ARG LIBDRM_VERSION=2.4.91
RUN yum install -y libdrm-${LIBDRM_VERSION} libdrm-devel-${LIBDRM_VERSION} && yum clean all

# Install build dependencies
RUN yum install -y automake autoconf bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial nasm yasm zlib-devel && yum clean all

# Build libva
ARG LIBVA_VERSION=1.8.1
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL https://www.freedesktop.org/software/vaapi/releases/libva/libva-${LIBVA_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
    ./configure CFLAGS=' -O2' CXXFLAGS=' -O2' --prefix=${PREFIX} --libdir=${LIBDIR} && \
    make && make install && \
    rm -rf ${DIR}

# Build libva-intel-driver
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL https://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/intel-vaapi-driver-${LIBVA_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
    ./configure && \
    make && make install && \
    rm -rf ${DIR}

# Build nasm
ARG NASM_VERSION=2.14.02
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.bz2" | \
    tar -jx --strip-components=1 && \
    ./autogen.sh && \
    ./configure --prefix=${PREFIX} --libdir=${LIBDIR} && \
    make && make install && \
    rm -rf ${DIR}

# Build yasm
ARG YASM_VERSION=1.3.0
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL "https://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz" | \
    tar -zx --strip-components=1 && \
    ./configure --prefix=${PREFIX} --libdir=${LIBDIR} && \
    make && make install && \
    rm -rf ${DIR}

# Build ffmpeg
ARG TARGET_VERSION=3.3
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL http://ffmpeg.org/releases/ffmpeg-${TARGET_VERSION}.tar.gz | \
    tar -zx --strip-components=1 && \
    ./configure \
        --prefix=${PREFIX} \
        --enable-small \
        --enable-gpl \
        --enable-vaapi \
        --disable-doc \
        --disable-debug && \
    make && make install && \
    make distclean && \
    hash -r && \
    rm -rf ${DIR} 

