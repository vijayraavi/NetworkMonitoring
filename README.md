![0]

# NetworkMonitoring

**Azure / NetworkMonitoring** is a repository for open source Azure network monitoring tools. Each tool or collection of tools lives in a folder under the main NetworkMonitoring repo.

The current tools/tool-sets are:
#### AzureCT
[AzureCT][AzureCT] is a collection of server side web pages and local PowerShell that will generate, collect, store, and display availability statistics of the network between you and a newly built Windows VM in Azure. It will do more in the future, but currently only provides availability information.

#### LogConverter
[LogConverter][LogConverter] contains code for downloading operational network logs and converting them to .CSV files. Files can then be uploaded to Power BI for analysis.

<!--Image References-->
[0]: ./AzureCT/media/AzureNMT.png "Azure Network Monitoring Tools"

<!--Link References-->
[LogConverter]: https://github.com/Azure/NetworkMonitoring/tree/master/LogConverter "LogConverter tree"
[AzureCT]: https://github.com/Azure/NetworkMonitoring/tree/master/AzureCT "AzureCT tree"
