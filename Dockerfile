FROM centos:7.3.1611
MAINTAINER Sho Fuji <pockawoooh@gmail.com>

CMD ["--help"]
ENTRYPOINT ["ffmpeg"]

WORKDIR /work

ENV TARGET_VERSION=3.3 \
    LIBVA_VERSION=1.8.1 \
    LIBDRM_VERSION=2.4.80 \
    SRC=/usr \
    PKG_CONFIG_PATH=/usr/lib/pkgconfig

RUN yum install -y --enablerepo=extras epel-release yum-utils && yum clean all

# Install libdrm
RUN yum install -y libdrm libdrm-devel && yum clean all

# Install build dependencies
RUN yum install -y automake autoconf bzip2 cmake freetype-devel gcc gcc-c++ git libtool make mercurial nasm yasm zlib-devel && yum clean all

# Build libva
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL https://www.freedesktop.org/software/vaapi/releases/libva/libva-${LIBVA_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
#    ./configure --help && exit 1 && \
    ./configure CFLAGS=' -O2' CXXFLAGS=' -O2' --prefix=${SRC} --libdir=/usr/lib64 && \
    make && make install && \
    rm -rf ${DIR}

# Build libva-intel-driver
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL https://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/intel-vaapi-driver-${LIBVA_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
    ./configure && \
    make && make install && \
    rm -rf ${DIR}

# Build ffmpeg
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL http://ffmpeg.org/releases/ffmpeg-${TARGET_VERSION}.tar.gz | \
    tar -zx --strip-components=1 && \
    ./configure \
        --prefix=${SRC} \
        --enable-small \
        --enable-gpl \
        --enable-vaapi \
        --disable-doc \
        --disable-debug && \
    make && make install && \
    make distclean && \
    hash -r && \
    rm -rf ${DIR} 

RUN ffmpeg -buildconf

