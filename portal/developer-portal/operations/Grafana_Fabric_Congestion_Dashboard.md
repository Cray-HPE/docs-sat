---
category: numbered
---

# Grafana Fabric Congestion Dashboard

![](images/Grafana_Fabric_Congestion.png)

SAT Grafana Dashboards provide system administrators a way to view fabric telemetry data across all Rosetta switches in the system and assess the past and present health of the high-speed network. It also allows the ability to drill down to view data for specific ports on specific switches.

This dashboard contains the variable, **Port Type** not found in the other dashboards. The possible values are *edge*, *local*, and *global* and correspond to the link's relationship to the network topology. The locations presented in the panels are restricted to the values \(any combination, defaults to "all"\) selected.

The metric values for links of a given port type are similar in value to each other but very distinct from the values of other types. If the values for different port types are all plotted together, the values for links with lower values are indistinguishable from zero when plotted.

The port type of a link is reported as a port state "subtype" event when defined at port initialization.

**Parent topic:**[SAT Grafana Dashboards](SAT_Grafana_Dashboards.md)

