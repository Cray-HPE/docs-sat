---
category: numbered
---

# SAT Kibana Dashboards

Kibana is an open source analytics and visualization platform designed to search, view, and interact with data stored in Elasticsearch indices. Kibana runs as a web service and has a browser-based interface. It offers visual output of node data in the forms of charts, tables and maps that display real-time Elasticsearch queries. Viewing system data in this way breaks down the complexity of large data volumes into easily understood information.

Additional details about the AER, ATOM, Heartbeat, Kernel, MCE, and Rasdaemon Kibana Dashboards are included in this table.

|Dashboard|Short Description|Long Description|Kibana Visualization and Search Name|
|---------|-----------------|----------------|------------------------------------|
|sat-aer|AER corrected|Corrected Advanced Error Reporting messages from PCI Express devices on each node.|Visualization: aer-corrected Search: sat-aer-corrected|
|sat-aer|AER fatal|Fatal Advanced Error Reporting messages from PCI Express devices on each node.|Visualization: aer-fatal Search: sat-aer-fatal|
|sat-atom|ATOM failures|Application Task Orchestration and Management tests are run on a node when a job finishes. Test failures are logged.|sat-atom-failed|
|sat-atom|ATOM admindown|Application Task Orchestration and Management test failures can result in nodes being marked admindown. An admindown node is not available for job launch.|sat-atom-admindown|
|sat-heartbeat|Heartbeat loss events|Heartbeat loss event messages reported by the hbtd pods that monitor for heartbeats across nodes in the system.|sat-heartbeat|
|sat-kernel|Kernel assertions|The kernel software performs a failed assertion when some condition represents a serious fault. The node goes down.|sat-kassertions|
|sat-kernel|Kernel panics|The kernel panics when something is seriously wrong. The node goes down.|sat-kernel-panic|
|sat-kernel|Lustre bugs \(LBUGs\)|The Lustre software in the kernel stack performs a failed assertion when some condition related to file system logic represents a serious fault. The node goes down.|sat-lbug|
|sat-kernel|CPU stalls|CPU stalls are serous conditions that can reduce node performance, and sometimes cause a node to go down. Technically these are Read-Copy-Update stalls where software in the kernel stack holds onto memory for too long. Read-Copy-Update is a vital aspect of kernel performance and rather esoteric.|sat-cpu-stall|
|sat-kernel|Out of memory|An Out Of Memory \(OOM\) condition has occurred. The kernel must kill a process to continue. The kernel will select an expendable process when possible. If there is no expendable process the node usually goes down in some manner. Even if there are expendable processes the job is likely to be impacted. OOM conditions are best avoided.|sat-oom|
|sat-mce|MCE|Machine Check Exceptions \(MCE\) are errors detected at the processor level.|sat-mce|
|sat-rasdaemon|rasdaemon errors|Errors from the `rasdaemon` service on nodes. The `rasdaemon` service is the Reliability, Availability, and Serviceability Daemon, and it is intended to collect all hardware error events reported by the linux kernel, including PCI and MCE errors. This may include certain HSN errors in the future.|sat-rasdaemon-error|
|sat-rasdaemon|rasdaemon messages|All messages from the `rasdaemon` service on nodes.|sat-rasdaemon|

-   **[AER Kibana Dashboard](AER_Kibana_Dashboard.md)**  

-   **[ATOM Kibana Dashboard](ATOM_Kibana_Dashboard.md)**  

-   **[Heartbeat Kibana Dashboard](Heartbeat_Kibana_Dashboard.md)**  

-   **[Kernel Kibana Dashboard](Kernel_Kibana_Dashboard.md)**  

-   **[MCE Kibana Dashboard](MCE_Kibana_Dashboard.md)**  

-   **[Rasdaemon Kibana Dashboard](Rasdaemon_Kibana_Dashboard.md)**  


**Parent topic:**[About the System Admin Toolkit \(SAT\)](About_the_System_Admin_Toolkit.md)

