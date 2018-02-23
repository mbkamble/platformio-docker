# platformio-docker
Build system for Arduino, STM32 and nRF5 IOT devices

This container contains the [platformio](https://platformio.org) a cross platform code builder and library manager with extensive support for IoT boards

Usage model of this docker container is as follows:
```
mkdir ~/docker-data/pio-builds

docker run --rm --name pio-build -ti -h pio-build -v ~/docker-data/pio-builds:/home/build/builds \
[--device /dev/ttyUSB0:/dev/ttyUSB0] mbkamble/platformio-docker

# A sample platformio.ini is available in /home/build/platformio.ini.template. To build a sample project

mkdir sample_project
cd sample_project
pio init
cp ../../platformio.ini.template platformio.ini
echo -e "void setup()\n{\n}\n\nvoid loop()\n{\n}\n" > scr/main.ino
pio run [-e uno]
```
