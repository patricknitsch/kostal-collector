# kostal-collector

Collect data from a Kostal Piko inverter via `dxs.json`.
The collected values are pushed to InfluxDB.

## Supported metrics

The collector uses an extendable metric definition with `name` + `dxs_id` + `field` + `type`.
Measurement fields and field types are configured in `lib/kostal_metrics.rb`.
Currently configured:

- `ID_DCEingangsleistung` (`33556736`)
- `ID_Ausgangsleistung` (`67109120`)
- `ID_DC1Leistung` (`33555203`)
- `ID_DC2Leistung` (`33555459`)
- `ID_DC3Leistung` (`33555715`)
- `ID_P1Leistung` (`67109379`)
- `ID_P2Leistung` (`67109635`)
- `ID_P3Leistung` (`67109891`)
- `ID_Status` (`16780032`)

## Usage

```bash
bundle install
KOSTAL_HOST=192.168.178.10 bundle exec ruby app.rb
```

Optional environment variables:

- `KOSTAL_HOST` (default: `kostal`)
- `KOSTAL_PROTOCOL` (default: `http`)
- `KOSTAL_PORT` (default: `80`)
- `KOSTAL_INTERVAL` in seconds (default: `10`)
- `INFLUX_SCHEMA` (default: `http`)
- `INFLUX_HOST` (default: `influxdb`)
- `INFLUX_PORT` (default: `8086`)
- `INFLUX_TOKEN`
- `INFLUX_ORG`
- `INFLUX_BUCKET`
- `INFLUX_MEASUREMENT` (default: `KOSTAL`)
