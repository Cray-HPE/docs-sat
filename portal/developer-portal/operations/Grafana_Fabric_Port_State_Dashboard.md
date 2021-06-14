---
category: numbered
---

# Grafana Fabric Port State Dashboard

![](Fabric_PortState_Locations_UI.png)

There is no **Interval** option because this parameter is not used to set a coarseness of the data. Only a single value is presented that displays the most recent value in the time range.

The Fabric Port State telemetry is distinct because it typically is not numeric. It also updates infrequently, so a long time range may be necessary to obtain any values. Port State is refreshed daily, so a time range of 24 hours results in all states for all links in the system being shown.

The three columns named, *group*, *switch*, and *port* are not port state events, but extra information included with all port state events.

**Parent topic:**[SAT Grafana Dashboards](SAT_Grafana_Dashboards.md)

