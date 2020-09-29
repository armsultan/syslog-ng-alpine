## Syslog-ng in Alpine Docker

### Basic Info
Minimal Alpine Docker container that writes logs to
`/var/log/syslog-ng/messages.log`.

Modified from [tekintian/syslog-ng-alpine](https://github.com/tekintian/syslog-ng-alpine),
[karantin2020/docker-syslog-ng](https://github.com/karantin2020/docker-syslog-ng), 
and the [balabit docker image's](https://github.com/balabit/syslog-ng-docker) config file

Includes a default config file if none specified, or alternatively use your own
by binding `/etc/syslog-ng`.

Uses [`Tini`](https://github.com/krallin/tini) for monitoring

Exposed inputs:

* 514/udp
* 601/tcp 
* 6514/TLS
* unix socket `/var/run/syslog-ng/syslog-ng.sock`

Exposed Volumes:
* `/var/log/syslog-ng` (Actual logging location)
* `/var/run/syslog-ng` (Unix Socket)
* `/etc/syslog-ng` (Config File)

### Usage

Syslog-ng will listen on ports `514`, `601` and forwards the logs into the file
`/var/log/syslog-ng`

You can override the default configuration by mounting a local
`/var/log/syslog-ng` configuration file as `/etc/syslog-ng/syslog-ng.conf`

Mount `/var/log/syslog-ng` too local directory to write files to host

Dockerfile expects a timezone, [`TZ`](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) passed as a build argument. If TZ is not passed as a build arg, go with `UTC`
 

For example:

```bash
# Build syslog-ng container
docker build -t syslog-ng . \
  --no-cache \
  --build-arg TZ=America/Denver

# Delete any existing container named "syslog-ng"
docker rm syslog-ng

# Run the container named "syslog-ng" and mount local local syslog-ng.conf
# and write logs to $PWD/logs

docker run --name syslog-ng -it -d \
    -p 514:514/udp \
    -p 601:601 \
    -v $PWD/syslog-ng.conf:/etc/syslog-ng/syslog-ng.conf \
    -v $PWD/slogs:/var/log/syslog-ng \
   syslog-ng

```

#### Docker-compose example

To start the Docker compose:

```bash
# Delete any existing container named "syslog-ng"
docker rm syslog-ng

docker-compose up --build -d
```

To stop the containers created: 

```
docker-compose down
```

For example the following config:
 * Export unix socket, by mounting `/var/run/syslog-ng`
 * Logs are forwarded to the host, by mounting `/var/log/syslog-ng`
 * We can use a local `syslog-ng.conf`, by mounting `/etc/syslog-ng/syslog-ng.conf`

```yml
version: '3'
services:
  syslog-ng:
    container_name: syslog-ng
    build: .
    ports:
      - "514:514/udp"
      - "601:601"
      - "6514:6514"
    volumes:
      - "./logs:/var/log/syslog-ng"
      - "./socket:/var/run/syslog-ng"
      # - "./config:/etc/syslog-ng/"
      - "./syslog-ng.conf:/etc/syslog-ng/syslog-ng.conf"
      - "./timezone:/etc/timezone:ro"
```

#### Test syslog using netcat

Run a quick test by sending a log to the container:

```bash
nc -w0 -u 127.0.0.1 514 <<< "testing again from my docker host machine"
```