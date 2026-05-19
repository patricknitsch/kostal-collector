[![Continuous integration](https://github.com/patricknitsch/kostal-collector/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/patricknitsch/kostal-collector/actions/workflows/docker-publish.yml)

# Kostal collector

Collects data from a Kostal Piko inverter via the local `dxs.json` API and pushes it to InfluxDB 2.
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

By default, the collector sends the following fields to InfluxDB (measurement `KOSTAL`):

| Field | DXS ID | Type |
|---|---|---|
| `dc_input_power` | `33556736` | float |
| `ac_output_power` | `67109120` | float |
| `dc_1_power` | `33555203` | float |
| `dc_2_power` | `33555459` | float |
| `dc_3_power` | `33555715` | float |
| `ac_1_power` | `67109379` | float |
| `ac_2_power` | `67109635` | float |
| `ac_3_power` | `67109891` | float |
| `status` | `16780032` | integer |

Field names, types and DXS IDs can be customized via `KOSTAL_METRICS` (see below).

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
| `INFLUX_MEASUREMENT_KOSTAL` | `KOSTAL` | Measurement name |

### Custom metrics

`KOSTAL_METRICS` allows overriding field names and types without rebuilding the image. Each entry has the format `dxs_id:field_name:type`, separated by commas or spaces. Entries matching a default DXS ID override that default; all other defaults are kept. New DXS IDs are appended.

Valid types: `float`, `integer`, `string`, `boolean` (aliases: `int`, `bool`)

Example — rename two fields, keep all others:

```
KOSTAL_METRICS=33556736:inverter_power:float,67109120:grid_feed_in:float
```

Example — full custom set:

```
KOSTAL_METRICS=33556736:dc_power:float,67109120:ac_power:float,16780032:status:integer
```

## License

Copyright (c) 2026 Patrick Nitsch, released under the MIT License
