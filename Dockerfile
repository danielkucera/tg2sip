FROM hectorvent/tg2sip-builder:buster as builder

WORKDIR /src/
COPY include ./include
COPY libtgvoip ./libtgvoip
COPY tg2sip ./tg2sip
COPY CMakeLists.txt ./
COPY settings.ini ./

RUN cmake -DCMAKE_BUILD_TYPE=Release . \
    && cmake --build .


# Final image
FROM debian:buster-slim

RUN apt-get update \
    && apt install libopus0 libssl1.1 -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/build/gen_db /usr/local/bin/gen_db
COPY --from=builder /src/build/tg2sip /usr/local/bin/tg2sip
COPY --from=builder /src/build/settings.ini /etc/tg2sip/settings.ini

# Enviroments
# YES / NO
# when this is enabled volumes will be used.
ENV TG2SIP_STANDARD_FOLDER YES

VOLUME /etc/tg2sip
VOLUME /var/tg2sip

CMD [ "tg2sip" ]