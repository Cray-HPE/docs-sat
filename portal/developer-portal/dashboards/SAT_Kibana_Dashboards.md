---
category: numbered
---

## SAT Kibana Dashboards

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

### Disable Search Highlighting in Kibana Dashboard

By default, search highlighting is enabled. This procedure instructs how to disable search highlighting.

The Kibana Dashboard should be open on your system.

-   **ROLE**
    -   System Administrator

-   **OBJECTIVE**

    Provide instructions to disable search highlighting within **Management**,**Advanced Settings**. If search highlighting is not needed, it can be distracting for the user.

-   **LIMITATIONS**

    This action applies to all searches, not just SAT dashboard searches.

-   **NEW IN THIS RELEASE**

    This entire procedure is new with this release.

1.  Navigate to **Management**

2.  Navigate to **Advanced Settings** in the Kibana section, below the Elastic search section

3.  Scroll down to the **Discover** section

4.  Change **Highlight results** from *on* to *off*

5.  Click **Save** to save changes

### AER Kibana Dashboard

The AER Dashboard displays errors that come from the PCI Express Advanced Error Reporting \(AER\) driver. These errors are split up into separate visualizations depending on whether they are fatal or corrected errors.

#### View the AER Kibana Dashboard

HPE Cray EX is installed on the system along with the System Admin Toolkit, which contains the AER Kibana Dashboard.

-   **ROLE**

    System administrator

-   **OBJECTIVE**

    View the AER Dashboard to see fatal or corrected errors for Shasta system nodes.


1.  Go to the dashboard section.

2.  Select **sat-aer** dashboard.

3.  Choose the time range of interest.

4.  View the Corrected and Fatal Advanced Error Reporting messages from PCI Express devices on each node. View the matching log messages in the panel\(s\) on the right, and view the counts of each message per NID in the panel\(s\) on the left. If desired, results can be filtered by NID by clicking the icon showing a **+** inside a magnifying glass next to each NID.

### ATOM Kibana Dashboard

The ATOM \(Application Task Orchestration and Management\) Dashboard displays node failures that occur during health checks and application test failures. Some test failures are of *possible* interest even though a node is not marked **admindown** or otherwise fails. They are of *clear* interest if a node is marked **admindown**, and might provide clues if a node otherwise fails. They might also show application problems.

#### View the ATOM Kibana Dashboard

HPE Cray EX is installed on the system along with the System Admin Toolkit, which contains the ATOM Kibana Dashboard.

-   **ROLE**

    System Administrator

-   **OBJECTIVE**

    View the ATOM Dashboard to select a time range to see ATOM errors for Shasta system nodes.


1.  Go to the dashboard section.

2.  Select **sat-atom** dashboard.

3.  Choose the time range of interest.

4.  View any nodes marked **admindown** and any ATOM test failures. These failures occur during health checks and application test failures. Test failures marked **admindown** are important to note. View the matching log messages in the panel\(s\) on the right, and view the counts of each message per NID in the panel\(s\) on the left. If desired, results can be filtered by NID by clicking the icon showing a **+** inside a magnifying glass next to each NID.



### Heartbeat Kibana Dashboard

The Heartbeat Dashboard displays heartbeat loss messages that are logged by the hbtd pods in the system. The hbtd pods are responsible for monitoring nodes in the system for heartbeat loss.

#### View the Heartbeat Kibana Dashboard

HPE Cray EX is installed on the system along with the System Admin Toolkit, which contains the Heartbeat Kibana Dashboard.

-   **ROLE**

    System administrator

-   **OBJECTIVE**

    View the Heartbeat Dashboard to select a time range to see heartbeat errors for Shasta system nodes.


1.  Go to the dashboard section.

2.  Select **sat-heartbeat** dashboard.

3.  Choose the time range of interest.

4.  View the heartbeat loss messages that are logged by the hbtd pods in the system. The hbtd pods are responsible for monitoring nodes in the system for heartbeat loss.View the matching log messages in the panel.

### Kernel Kibana Dashboard

The Kernel Dashboard displays compute node failures such as kernel assertions, kernel panics, and Lustre LBUG messages. The messages reveal if Lustre has experienced a fatal error on any compute nodes in the system. A CPU stall is a serious problem that might result in a node failure. Out-of-memory conditions can be due to applications or system problems and may require expert analysis. They provide useful clues for some node failures and may reveal if an application is using too much memory.

#### View the Kernel Kibana Dashboard

HPE Cray EX is installed on the system along with the System Admin Toolkit, which contains the Kernel Kibana Dashboard.

-   **ROLE**

    System administrator

-   **OBJECTIVE**

    View the Kernel Dashboard to select a time range to see kernel errors for Shasta system nodes.

1.  Go to the dashboard section.

2.  Select **sat-kernel** dashboard.

3.  Choose the time range of interest.

4.  View the compute node failures such as kernel assertions, kernel panics, and Lustre LBUG messages. View the matching log messages in the panel\(s\) on the right, and view the counts of each message per NID in the panel\(s\) on the left. If desired, results can be filtered by NID by clicking the icon showing a **+** inside a magnifying glass next to each NID.

### MCE Kibana Dashboard

The MCE Dashboard displays CPU detected processor-level hardware errors.

#### View the MCE Kibana Dashboard

HPE Cray EX is installed on the system along with the System Admin Toolkit, which contains the MCE Kibana Dashboard.

-   **ROLE**

    System administrator

-   **OBJECTIVE**

    View the MCE Dashboard to select a time range to see MCE errors for Shasta system nodes.


1.  Go to the dashboard section.

2.  Select **sat-mce** dashboard.

3.  Choose the time range of interest.

4.  View the Machine Check Exceptions \(MCEs\) listed including the counts per NID \(node\). For an MCE, the CPU number and DIMM number can be found in the message, if applicable. View the matching log messages in the panel\(s\) on the right, and view the counts of each message per NID in the panel\(s\) on the left. If desired, results can be filtered by NID by clicking the icon showing a **+** inside a magnifying glass next to each NID.

### Rasdaemon Kibana Dashboard

The Rasdaemon Dashboard displays errors that come from the Reliability, Availability, and Serviceability \(RAS\) daemon service on nodes in the system. This service collects all hardware error events reported by the linux kernel, including PCI and MCE errors. As a result there may be some duplication between the messages presented here and the messages presented in the MCE and AER dashboards. This dashboard splits up the messages into two separate visualizations, one for only messages of severity "emerg" or "err" and another for all messages from `rasdaemon`.

#### View the Rasdaemon Kibana Dashboard

HPE Cray EX is installed on the system along with the System Admin Toolkit, which contains the Rasdaemon Kibana Dashboard.

-   **ROLE**

    System administrator

-   **OBJECTIVE**

    View the Rasdaemon Dashboard to select a time range to see `rasdaemon` errors for Shasta system nodes.

1.  Go to the dashboard section.

2.  Select **sat-rasdaemon** dashboard.

3.  Choose the time range of interest.

4.  View the errors that come from the Reliability, Availability, and Serviceability \(RAS\) daemon service on nodes in the system.View the matching log messages in the panel\(s\) on the right, and view the counts of each message per NID in the panel\(s\) on the left. If desired, results can be filtered by NID by clicking the icon showing a **+** inside a magnifying glass next to each NID.

