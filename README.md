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

### Use the image directly with Docker

Pull and start the published image:

```bash
docker pull ghcr.io/patricknitsch/kostal-collector:latest
docker run --rm --env-file .env ghcr.io/patricknitsch/kostal-collector:latest
```

Build and run locally from source:

```bash
docker build -t kostal-collector:local .
docker run --rm --env-file .env kostal-collector:local
```

## Output

Two output targets are supported:

- `OUTPUT_TARGET=influxdb` (default)
- `OUTPUT_TARGET=mqtt`

For InfluxDB, metrics are sent only if explicitly configured via `KOSTAL_METRICS`.
For MQTT, all supported metrics are published automatically (see `KOSTAL_CONSUMPTION` to reduce the set).

## Environment variables

### Kostal inverter

| Variable | Default | Description |
|---|---|---|
| `KOSTAL_HOST` | `kostal` | Hostname or IP of the inverter |
| `KOSTAL_PROTOCOL` | `http` | Protocol (`http` or `https`) |
| `KOSTAL_PORT` | `80` | Port |
| `KOSTAL_INTERVAL` | `10` | Polling interval in seconds |
| `KOSTAL_CONSUMPTION` | `true` | Set to `false` to exclude home consumption, self-sufficiency, and battery metrics (for generation-only inverters without storage) |

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

### Custom metrics (InfluxDB only)

`KOSTAL_METRICS` defines the complete set of exported fields for InfluxDB output.  
Each entry has the format `dxs_id:field_name:type`, separated by commas or spaces.

Valid types: `float`, `integer`, `string`, `boolean` (aliases: `int`, `bool`)

Example:

```
KOSTAL_METRICS=33556736:dc_power:float,67109120:ac_power:float,16780032:status:integer
```

### Supported DXS IDs

The adapter can read the following DXS IDs (MQTT publishes all of them unless filtered by `KOSTAL_CONSUMPTION`):

| DXS ID | Field | Excluded by `KOSTAL_CONSUMPTION=false` |
|---|---|---|
| `33556736` | DCEingangGesamt | |
| `67109120` | Ausgangsleistung | |
| `83888128` | Eigenverbrauch | ✓ |
| `83887872` | Hausverbrauch | ✓ |
| `16780032` | Status | |
| `16777984` | WRName | |
| `16779267` | WRArtikel | |
| `16780544` | WRSeriennummer | |
| `251658754` | Ertrag_d | |
| `251659010` | Hausverbrauch_d | ✓ |
| `251659266` | Eigenverbrauch_d | ✓ |
| `251659278` | Eigenverbrauchsquote_d | ✓ |
| `251659279` | Autarkiegrad_d | ✓ |
| `251658753` | Ertrag_G | |
| `251659009` | Hausverbrauch_G | ✓ |
| `251659265` | Eigenverbrauch_G | ✓ |
| `251659280` | Eigenverbrauchsquote_G | ✓ |
| `251659281` | Autarkiegrad_G | ✓ |
| `251658496` | Betriebszeit | |
| `33555202` | DC1Spannung | |
| `33555201` | DC1Strom | |
| `33555203` | DC1Leistung | |
| `33555458` | DC2Spannung | |
| `33555457` | DC2Strom | |
| `33555459` | DC2Leistung | |
| `33555714` | DC3Spannung | |
| `33555713` | DC3Strom | |
| `33555715` | DC3Leistung | |
| `33556226` | BatterieSOC | ✓ |
| `33556227` | BatterieStatus | ✓ |
| `33556228` | BatterieStrom | ✓ |
| `33556229` | BatterieSpannung | ✓ |
| `33556230` | BatterieLeistung | ✓ |
| `33556238` | BatterieTemp | ✓ |
| `83886336` | HausverbrauchSolar | ✓ |
| `83886592` | HausverbrauchBatterie | ✓ |
| `83886848` | HausverbrauchNetz | ✓ |
| `83887106` | HausverbrauchPhase1 | ✓ |
| `83887362` | HausverbrauchPhase2 | ✓ |
| `83887618` | HausverbrauchPhase3 | ✓ |
| `67110400` | NetzFrequenz | |
| `67110656` | NetzCosPhi | |
| `67110144` | NetzEinspeiselimit | |
| `67109378` | P1Spannung | |
| `67109377` | P1Strom | |
| `67109379` | P1Leistung | |
| `67109634` | P2Spannung | |
| `67109633` | P2Strom | |
| `67109635` | P2Leistung | |
| `67109890` | P3Spannung | |
| `67109889` | P3Strom | |
| `67109891` | P3Leistung | |
| `167772417` | Analogeingang1 | |
| `167772673` | Analogeingang2 | |
| `167772929` | Analogeingang3 | |
| `167773185` | Analogeingang4 | |

## License

Copyright (c) 2026 Patrick Nitsch, released under the MIT License
