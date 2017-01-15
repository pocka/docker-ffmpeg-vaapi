FROM centos:7.3.1611
MAINTAINER Sho Fuji <pockawoooh@gmail.com>


CMD ["--help"]
ENTRYPOINT ["ffmpeg"]

WORKDIR /work

ENV TARGET_VERSION=3.2.2 \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN yum install -y --enablerepo=extras epel-release yum-utils && \
    # Install vaapi
    yum-config-manager --add-repo=http://negativo17.org/repos/epel-multimedia.repo && \
    yum install -y libva libva-devel libva-intel-driver && \
    # Install build dependencies
    build_deps="automake autoconf bzip2 \
                cmake freetype-devel gcc \
                gcc-c++ git libtool make \
                mercurial nasm pkgconfig \
                yasm zlib-devel" && \
    yum install -y ${build_deps} && \
    # Build ffmpeg
    DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL http://ffmpeg.org/releases/ffmpeg-${TARGET_VERSION}.tar.gz | \
    tar -zx --strip-components=1 && \
    ./configure \
        --enable-nonfree \
        --enable-small \
        --enable-gpl \
        --disable-doc \
        --disable-debug && \
    make && make install && \
    make distclean && \
    hash -r && \
    # Cleanup build dependencies and temporary files
    rm -rf ${DIR} && \
    yum history -y undo last && \
    yum clean all && \
    ffmpeg -buildconf
