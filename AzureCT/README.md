# Azure Connectivity Toolkit (AzureCT)

## Overview
The Azure Connectivity Toolkit (AzureCT) is a PowerShell module and collection of server side web pages which can test, generate, collect, store, and display performance and availability statistics of the network between you and Azure. The two main areas of functionality are:

 - [Network Performance Testing][Performance Doc]: The Get-LinkPerformance command runs a series of iPerf3 bandwidth load tests while concurrently doing a TCP ping to show latency under various loads.
 - [Network Availability Testing][Availability Doc]: The Get-AzureNetworkAvailability command runs pings and traceroutes over an extended period of time to show end to end availability and hop latency.

----------

## [Link Performance][Performance Doc]

[![1]][1]

This collection of PowerShell commandlets will download required files to run the Get-LinkPerformance command which runs a series of iPerf load tests and PSPing TCP pings concurrently between a local source and a remote host running iPerf3 in server mode. Six tests of increasing load are performed and results are output at the conclusion of the test. This testing is designed to show link latency and bandwidth capabilities under various conditions.

**Requirements**: Link Performance testing requires a local Windows machine from which PowerShell is run and a remote host, either Linux or Windows, running iPerf3 and listening on an admin port either 22 for Linux or 3389 for Windows.

To install and test Link Performance follow the instructions here: [Performance Testing Instructions][Performance Doc]

## [Link Availability][Availability Doc]

[![0]][0]

This collection of server side web pages and local PowerShell that will generate, collect, store, and display availability statistics of the network between you and a newly built Windows VM in Azure.

It is designed to provide an indication, over time, of the link between a Virtual Machine in Azure and an on-premise network. While the focus is on network availability, the test is done from a PC client to an IIS server in Azure. This provides a view into the availability of an end-to-end scenario, not just a single point or component in the complex chain that makes up a VPN or an ExpressRoute network connection. The hope is that this will provide insight into the end-to-end network availability.

**Requirements**: Link Availability testing requires a local Windows machine from which PowerShell is run and a newly built remote Windows VM running IIS and a small web application.

To install and test Link Performance follow the instructions here: [Availability Testing Instructions][Availability Doc]

>**Note**: These tools are not certified by Microsoft, nor are they supported by Microsoft support. Download and use at your own risk. While the author is an employee of Microsoft, these tools are provided as my best effort to provide insight into the connectivity between an on-premise network and an Azure endpoint. See the [Support and Legal Disclaimers](#support-and-legal-disclaimers) below for more info.

## Removing the Azure Connectivity Toolkit
Once testing is complete the Azure VM can be deleted to avoid unnecessary Azure usage (and associated charges) and all local files can be deleted. The only files on the local machine are the PowerShell module files copied from GitHub, iPerf and PSPPing files in the C:\ACTTools directory (if Install-LinkPerformance was run), and potentially three XML files (if Get-AzureNetworkAvailability was run) in the Local Client PC %temp% directory.

To ensure 100% removal of all artifacts from the Azure Connectivity Toolkit perform the following step:

1. Run the Remove-AzureCT command from PowerShell. This will remove the PowerShell module and any local data files.

	```powershell
	Remove-AzureCT
	```

## History

 - 2016-02-03 - Initial beta release 1.6.0.1
 - 2016-02-07 - Updated beta release 1.6.0.2
 - 2016-02-22 - Added more functions and client side trace 1.9.0.1
 - 2017-06-26 - Added link performance related commands

## Incorporated Licenses
This tool incorporates [JQuery](https://jquery.org/license/ "JQuery License") for XML manipulation and is included in the ServerSide files. JQuery.js is included and used under the requirements of the MIT License, and in compliance with the main JQuery license proviso "*You are free to use any jQuery Foundation project in any other project (even commercial projects) as long as the copyright header is left intact.*"

## Support and Legal Disclaimers
Microsoft provides no support for this software. All support, assistance, and information is on this site alone.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; INCREMENTAL AZURE COSTS INCURRED THROUGH USE OF THIS SOFTWARE; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<!--Image References-->
[0]: ./media/AzureCTAvailability.png "AzureCT Availability Test Diagram"
[1]: ./media/AzureCTPerformance.png "AzureCT Performance Test Diagram"

<!--Link References-->
[Performance Doc]: ./PerformanceTesting.md
[Availability Doc]: ./AvailabilityTesting.md
