[![Continuous integration](https://github.com/patricknitsch/kostal-collector/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/patricknitsch/kostal-collector/actions/workflows/docker-publish.yml)

# Kostal collector

Collects data from a Kostal Piko inverter via the local `dxs.json` API and pushes it to InfluxDB 2 or MQTT.
The concept and structure based on the **Senec-Collector** and the great work of the hole project **SOLECTRUS** from **ledermann**.

## Requirements

Linux machine with Docker installed, InfluxDB 2 database

## Getting started

1. Prepare a Linux box (Raspberry Pi, Synology NAS, ...) with Docker installed

2. Make sure your InfluxDB 2 database is ready (not subject of this README)

3. Prepare an `.env` file (see `.env.example`)

4. Run the Docker container on your Linux box:

   ```bash
   docker compose up
   ```

The Docker image supports multiple platforms: `linux/amd64`, `linux/arm64`, `linux/arm/v7`

## Output

Two output targets are supported:

- `OUTPUT_TARGET=influxdb` (default)
- `OUTPUT_TARGET=mqtt`

Metrics are sent only if they are explicitly configured in `KOSTAL_METRICS`.
There are no default metric-to-field mappings.

## Environment variables

### Kostal inverter

| Variable | Default | Description |
|---|---|---|
| `KOSTAL_HOST` | `kostal` | Hostname or IP of the inverter |
| `KOSTAL_PROTOCOL` | `http` | Protocol (`http` or `https`) |
| `KOSTAL_PORT` | `80` | Port |
| `KOSTAL_INTERVAL` | `10` | Polling interval in seconds |

### InfluxDB

| Variable | Default | Description |
|---|---|---|
| `INFLUX_HOST` | `influxdb` | InfluxDB hostname |
| `INFLUX_SCHEMA` | `http` | Protocol (`http` or `https`) |
| `INFLUX_PORT` | `8086` | InfluxDB port |
| `INFLUX_TOKEN` | — | InfluxDB API token (required) |
| `INFLUX_ORG` | — | InfluxDB organisation (required) |
| `INFLUX_BUCKET` | — | InfluxDB bucket (required) |
| `INFLUX_MEASUREMENT_KOSTAL` | — | Measurement name (required for Influx output) |

### MQTT

| Variable | Default | Description |
|---|---|---|
| `MQTT_HOST` | — | MQTT broker hostname (required for MQTT output) |
| `MQTT_PORT` | `1883` | MQTT broker port |
| `MQTT_USERNAME` | — | Username (optional) |
| `MQTT_PASSWORD` | — | Password (optional) |
| `MQTT_TOPIC_PREFIX` | `kostal` | Topic prefix |
| `MQTT_RETAIN` | `false` | Retain flag (`true`/`false`) |

Published topics are `<MQTT_TOPIC_PREFIX>/measure_time` and `<MQTT_TOPIC_PREFIX>/<field>`.

### Output target

| Variable | Default | Description |
|---|---|---|
| `OUTPUT_TARGET` | `influxdb` | Output target: `influxdb` or `mqtt` |

### Custom metrics

`KOSTAL_METRICS` defines the complete set of exported fields.  
Each entry has the format `dxs_id:field_name:type`, separated by commas or spaces.

Valid types: `float`, `integer`, `string`, `boolean` (aliases: `int`, `bool`)

Example:

```
KOSTAL_METRICS=33556736:dc_power:float,67109120:ac_power:float,16780032:status:integer
```

### Supported DXS IDs

The adapter can read the following DXS IDs (example mapping names from Kostal API docs):

`33556736, 67109120, 83888128, 16780032, 251658754, 251659010, 251659266, 251659278, 251659279, 251658753, 251659009, 251659265, 251659280, 251659281, 251658496, 33555202, 33555201, 33555203, 33555458, 33555457, 33555459, 83886336, 83886592, 83886848, 83887106, 83887362, 83887618, 67110400, 67110656, 67109378, 67109377, 67109379, 67109634, 67109633, 67109635, 67109890, 67109889, 67109891`

## License

Copyright (c) 2026 Patrick Nitsch, released under the MIT License
