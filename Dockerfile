FROM debian:buster-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential git \
		wget ca-certificates \
		pkg-config libopus-dev libssl-dev \
		zlib1g-dev gperf ccache \
	&& rm -rf /var/lib/apt/lists/*

RUN wget https://cmake.org/files/v3.9/cmake-3.9.6-Linux-x86_64.sh \
    && sh cmake-3.9.6-Linux-x86_64.sh --prefix=/usr --exclude-subdir \
    && rm -rf cmake-3.9.6-Linux-x86_64.sh


RUN git clone https://github.com/tdlib/td.git \
    && cd td \
    && git reset --hard v1.2.0 \
    # && git reset --hard v1.5.0 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . --target install \
    && cd / \
    && rm -rf td

COPY config_site.h /

RUN git clone https://github.com/pjsip/pjproject.git \
    && cd pjproject \
    && git reset --hard 2.9 \
    && cp /config_site.h pjlib/include/pj \
    && ./configure --disable-sound CFLAGS="-O3 -DNDEBUG" \
    && make dep && make && make install \
    && cd / \
    && rm -rf pjproject \
    && rm -rf config_site.h 

RUN git clone -n https://github.com/gabime/spdlog.git \
    && cd spdlog \
    && git checkout tags/v0.17.0 \
    # && git checkout tags/v1.4.2 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DSPDLOG_BUILD_EXAMPLES=OFF -DSPDLOG_BUILD_TESTING=OFF .. \
    && cmake --build . --target install \
    && cd / \
    && rm -rf spdlog

WORKDIR /src/
COPY include ./include
COPY libtgvoip ./libtgvoip
COPY tg2sip ./tg2sip
COPY CMakeLists.txt ./

RUN cmake -DCMAKE_BUILD_TYPE=Release . \
    && cmake --build .

# Final image
FROM debian:buster-slim

RUN apt-get update \
    && apt install libopus0 libssl1.1 -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/build/gen_db /usr/bin/gen_db
COPY --from=builder /src/build/tg2sip /usr/bin/tg2sip
COPY settings.ini /etc/tg2sip/settings.ini

# Enviroments
# YES / NO
# when this is enabled volumes will be used.
ENV TG2SIP_STANDARD_FOLDER YES

VOLUME /etc/tg2sip
VOLUME /var/tg2sip

CMD [ "tg2sip" ]
