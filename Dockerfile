# 1. Build the image locally:
# docker build -t flutter-android .
# 2. Build inside the image locally (e.g. test CI on local device)
# docker run -v /home/can/hdm/morphing-interior/mi_client:/app -it flutter-android

FROM  javiersantos/android-ci:28.0.3

MAINTAINER kattwinkel@w11k.de

RUN apt-get -qq update && \
  apt-get install -qqy --no-install-recommends \
  xz-utils \
  jq \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN yes | sdk/tools/bin/sdkmanager --licenses
RUN yes | sdk/tools/bin/sdkmanager --install "cmdline-tools;latest"

# Updating build tools to meet flutter requirements 
RUN /sdk/tools/bin/sdkmanager "platforms;android-31" "build-tools;29.0.3"

ENV FLUTTER_VERSION 2.10.5-stable
WORKDIR /

RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_VERSION.tar.xz && \
  tar xf flutter_linux_$FLUTTER_VERSION.tar.xz && \
  rm -rf flutter_linux_$FLUTTER_VERSION.tar.xz

ENV PATH $PATH:/sdk/tools/bin/
ENV PATH $PATH:/flutter/bin/cache/dart-sdk/bin:/flutter/bin

RUN yes | flutter doctor --android-licenses
RUN flutter doctor

ENTRYPOINT ["./projects/ci_script.sh"]

