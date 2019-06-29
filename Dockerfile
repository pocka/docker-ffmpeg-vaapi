# https://trac.ffmpeg.org/wiki/CompilationGuide/Centos

FROM centos
MAINTAINER SuperFlyXXI <superflyxxi@yahoo.com>

ARG SRC_DIR=/ffmpeg

CMD ["--help"]
ENTRYPOINT ["ffmpeg"]

ARG PKG_CONFIG_PATH=/usr/lib/pkgconfig
ENV PATH=${PATH}:${SRC_DIR}/bin

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
    ./configure CFLAGS=' -O2' CXXFLAGS=' -O2' --prefix=/usr --libdir=/usr/lib64 && \
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
#    ./configure --prefix="${SRC_DIR}/build" --bindir="${SRC_DIR}/bin" && \
    ./configure --prefix="/usr" --libdir="/usr/lib64" && \
    make && make install && \
    rm -rf ${DIR}

# Build yasm
ARG YASM_VERSION=1.3.0
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL "https://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz" | \
    tar -zx --strip-components=1 && \
    #./configure --prefix="${SRC_DIR}/build" --bindir="${SRC_DIR}/bin" && \
    ./configure --prefix="/usr" --libdir="/usr/lib64" && \
    make && make install && \
    rm -rf ${DIR}

# Build x264
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
    cd x264 && \
    PKG_CONFIG_PATH="${SRC_DIR}/build/lib/pkgconfig" ./configure --prefix="${SRC_DIR}/build" --bindir="${SRC_DIR}/bin" --enable-static && \
    make && make install && \
    rm -rf ${DIR}

# Build x265
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    hg clone https://bitbucket.org/multicoreware/x265 && \
    cd x265/build/linux && \
     cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${SRC_DIR}/build" -DENABLE_SHARED:bool=off ../../source && \
    make && make install && \
    rm -rf ${DIR}

# Build fdk_aac
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
    cd fdk-aac && \
    autoreconf -fiv && \
    ./configure --prefix="${SRC_DIR}/build" --disable-shared && \
    make && make install && \
    rm -rf ${DIR}

# Build libvpx
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
    cd libvpx && \
    ./configure --prefix="${SRC_DIR}/build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
    make && make install && \
    rm -rf ${DIR}

# Build ffmpeg
ARG TARGET_VERSION=snapshot
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL http://ffmpeg.org/releases/ffmpeg-${TARGET_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
    PATH="${SRC_DIR}/bin:$PATH" PKG_CONFIG_PATH="${SRC_DIR}/build/lib/pkgconfig" ./configure \
        --prefix="${SRC_DIR}/build" \
        --pkg-config-flags="--static" \
        --extra-cflags="-I${SRC_DIR}/build/include" \
        --extra-ldflags="-L${SRC_DIR}/build/lib" \
        --extra-libs=-lpthread \
        --extra-libs=-lm \
        --bindir="${SRC_DIR}/bin" \
        --enable-small \
        --enable-gpl \
        --enable-libx265 \
        --enable-libx264 \
        --enable-vaapi \
        --enable-libfdk_aac --enable-nonfree \
        --enable-libvpx \
        --disable-doc \
        --disable-debug && \
    make && make install && \
    make distclean && \
    hash -r && \
    rm -rf ${DIR} 

