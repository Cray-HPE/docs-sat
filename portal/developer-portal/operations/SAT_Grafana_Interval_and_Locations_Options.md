---
category: numbered
---

# SAT Grafana Interval and Locations Options

Shows the Interval and Locations Options for the available telemetry.

## Interval and Locations Options

![](images/SAT_Grafana_Fabric_Vars.png)

The value of the **Interval** option sets the time resolution of the received telemetry. This works a bit like a histogram, with the available telemetry in an interval of time going into a "bucket" and averaging out to a single point on the chart or table. The special value *auto* will choose an interval based on the time range selected.

For additional information, refer to [Grafana Templates and Variables](https://grafana.com/docs/grafana/latest/reference/templating/#interval-variables).

The **Locations** option allows restriction of the telemetry shown by locations, either individual links or all links in a switch. The selection presented updates dynamically according to time range, except for the errors dashboard, which always has entries for all links and switches, although the errors shown are restricted to the selected time range.

The chart panels for the RFC3635 and Congestion dashboards allow selection of a single location from the chart's legend or the trace on the chart.

**Parent topic:**[SAT Grafana Dashboards](SAT_Grafana_Dashboards.md)

