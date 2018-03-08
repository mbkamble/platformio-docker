FROM ubuntu:16.04

LABEL maintainer="Milind Kamble <milindbkamble+foss@gmail.com"
LABEL description="Platformio Development Container for select IoT boards"

# Install Ubuntu packages
RUN apt-get update && \
    apt-get install -y python2.7 python-pip vim stm32flash libusb-1.0-0

# Install platformio
RUN pip install -U platformio
COPY 99-platformio-udev.rules /lib/udev/rules.d/99-platformio-udev.rules

# Add user "build" and set permissions to access suitable devices
RUN useradd -ms /bin/bash build && usermod -a -G dialout build && usermod -a -G plugdev build

# Put useful platformio template file in home directory
USER build
WORKDIR /home/build/
COPY platformio.ini.template /home/build/platformio.ini.template

# Predownload Uno, Due, blackpill(genericSTM32F103C8), nRF5 (waveshareBLE400)  framework
RUN mkdir /home/build/temp/ && \
    cd /home/build/temp/ && \
    pio update && \
    pio init --board uno --board due --board waveshare_ble400 --board genericSTM32F103C8 && \
    rm /home/build/temp/platformio.ini && \
    cp /home/build/platformio.ini.template /home/build/temp/platformio.ini && \
    echo "void setup(){} void loop(){}" > /home/build/temp/src/main.ino && \
    (pio run -e uno -t upload || pio run -e due -t upload || pio run -e blackpill -t upload || pio run -e waveshare_ble400 -t upload || true) && \
    cd /home/build/ && \
    rm -fr /home/build/temp/

# Create builds directory as a volume
RUN mkdir /home/build/builds \
    && chown -R build:build /home/build/builds

# tool-stm32duino is specified as version 1.0.0 in ~/.platformio/platforms/ststm32/platform.json and accordingly
# it downloads and installs https://dl.bintray.com/platformio/dl-packages/tool-stm32duino-linux_x86_64-1.0.0.tar.gz
# This stm32duino-1.0.0.tgz has binaries of upload-reset and dfu-util that do not run. Hence we overwrite them
# with freshly compiled version from the latest release of Arduino_STM32
COPY upload-reset /home/build/.platformio/packages/tool-stm32duino/
COPY dfu-util /home/build/.platformio/packages/tool-stm32duino/dfu-util/

VOLUME ["/home/build/builds"]

# Final setup
COPY docker-entrypoint.sh /
ENV PATH /home/build/:$PATH
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
