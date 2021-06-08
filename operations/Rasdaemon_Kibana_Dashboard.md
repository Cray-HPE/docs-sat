---
category: numbered
---

# Rasdaemon Kibana Dashboard

The Rasdaemon Dashboard displays errors that come from the Reliability, Availability, and Serviceability \(RAS\) daemon service on nodes in the system. This service collects all hardware error events reported by the linux kernel, including PCI and MCE errors. As a result there may be some duplication between the messages presented here and the messages presented in the MCE and AER dashboards. This dashboard splits up the messages into two separate visualizations, one for only messages of severity "emerg" or "err" and another for all messages from `rasdaemon`.

**Parent topic:**[SAT Kibana Dashboards](SAT_Kibana_Dashboards.md)

