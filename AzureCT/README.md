# Azure Connectivity Toolkit (AzureCT)

## Overview
The Azure Connectivity Toolkit (AzureCT) is a PowerShell module and collection of server side web pages will test, generate, collect, store, and display performance and availability statistics of the network between you and Azure. The two main areas of functionality are:

 - [A network availability test](#link-availability) (Get-AzureNetworkAvailability) that runs pings and traceroutes over an extended period of time to show end to end availability and hop latency.
 - [A bandwidth and latency tester](#link-performance) (Get-LinkPerformance) that runs a series of iPerf3 load tests while concurrently doing a TCP ping to show latency under various loads.

## Link Performance
This collection of PowerShell commandlets will download required files to run the Get-LinkPerformance which runs a series of iPerf load tests and PSPing TCP pings concurrently between a local source and a remote host running iPerf3 in server mode. Seven tests of increasing load are performed and results are output at the conclusion of the test.

![0]

>**Note**: This tool is not certified by Microsoft, nor is it supported by Microsoft support. Download and use at your own risk. While the author is an employee of Microsoft, this tool is provided as my best effort to provide insight into the connectivity between an on-premise network and an Azure endpoint. See the [Support and Legal Disclaimers](#support-and-legal-disclaimers) below for more info.

### Fast Start
If you just want to install the toolkit, this is a the place to start:

1. Install iPerf3 on a host (Linux or Windows) on the "far end" or remote side of the network link you're testing. If the remote host is a Window machine you can install the AzureCT and run the Install command mentioned below to install and configure iPerf. If there is a host firewall ensure port 5201 is open to allow iPerf to run.
2. On the local "near end" host run the following command from PowerShell to install the AzureCT PowerShell module: **(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Azure/NetworkMonitoring/master/AzureCT/PowerShell/Install-AzureCT.ps1") | Invoke-Expression**
3. Run the Install-LinkPerformance this will download PSPing and iPerf as well as configure your windows firewall to allow ICMP and iPerf.
4. On your local host you now have the Get-LinkPerformance command to run availability tests!

### Tool Usage
The Get-LinkPerformance command will run a series of iPerf load tests and PSPing TCP pings concurrently between a local source and a remote host running iPerf3 in server mode. Six tests of increasing load are performed and results are output at the conclusion of the test.

The remote server must be running iPerf3 in server mode; e.g iPerf3 -s

On the local server from which this function is run, various parameters can be used to affect the testing. The output is a combination of both the load test and the latency test while the performance test is running.

Each row of output represents the summation of a given test, the follow test conditions are run:
- No load, a PSPing TCP test without iPerf3 running, a pure TCP latency test
- 1 Session, a PSPing TCP test with iPerf3 running a single thread of load
- 6 Sessions, a PSPing TCP test with iPerf3 running a six thread load test
- 16 Sessions, a PSPing TCP test with iPerf3 running a 16 thread load test
- 16 Sessions with 1 Mb window, a PSPing TCP test with iPerf3 running a 16 thread load test with a 1 Mb window
- 32 Sessions, a PSPing TCP test with iPerf3 running a 32 thread load test

For each test iPerf is started and allowed to run for 10 seconds to establish the load and allow it to level. PSPing is then started to record latency during the load test.

Results from each test are stored in a text file in the root user profile directory ($env:USERPROFILE)

Output for each test is displayed in a table formatted object with the following columns:

- Name: The name of the test for these values, e.g. No load, 1 session, etc
- Bandwidth: The average bandwidth achieved by iPerf for the given test
- Loss: percentage of packets lost during the PSPing test
- P50 Latency: the 50th percentile of latency seen during the test

If the Verbose option (-Verbose) is used the following columns are also output:

- P90 Latency: the 90th percentile of latency seen during the test
- P95 Latency: the 95th percentile of latency seen during the test
- Avg Latency: the average TCP ping latency seen during the test
- Min Latency: the minimum TCP ping latency seen during the test
- Max Latency: the maximum TCP ping latency seen during the test

#### Prerequisites
This tool has three perquisite resources that must be in place before using:

1. An Azure virtual network with a VPN or ExpressRoute site-to-site connection to another (usually "on-premise") network.
2. A remote host running iPerf3 (compatible with iPerf3.1.3) in server mode (e.g. "iPerf3 -s") with the local firewall allowing port 5201 iPerf traffic as well as the admin port (3389 for Windows or 22 for Linux) open for the TCP ping traffic.
3. A client PC (or server) running PowerShell 3.0 or greater on the on-premise network that can reach the remote VM.

#### Installation Instructions
1. Local Host Instructions:
	- Install the AzureCT PowerShell module by running the following command in a PowerShell prompt:

		```powershell
		(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Azure/NetworkMonitoring/master/AzureCT/PowerShell/Install-AzureCT.ps1") | Invoke-Expression
		```
	- This will install a new PowerShell module with eight PowerShell cmdlets; Get-AzureNetworkAvailability, Clear-AzureCTHistory, Show-AzureCTResults, Get-HostName, Get-IPTrace, Remove-AzureCT, Install-LinkPerformance, and Get-LinkPerformance.
	- Run the Install-LinkPerformance command to download iPerf and PSPing as well as set the firewall rules. Note: The -Force option can be used for unattended installations.
2. Remote Host Instructions
	- Install iPerf3: [http://iperf.fr](http://iperf.fr)
	- Start iPerf3 in server mode (e.g. "iPerf3 -s")
	- Open firewall port 5201 (default iPerf3 port)
	- Ensure host is listen on the admin port (3389 for windows or 22 or Linux) 

#### Running the Tool
1. On the local host, open a PowerShell prompt.
2. Run the Install-LinkPerformance. This command only needs to be run once for a given host. However if required files are deleted or the host is configured so that Get-LinkPerformance can't run successfully you will be prompted to run Install-LinkPerformance again to get the host enabled for successful testing.
3. The main cmdlet is Get-LinkPerformance. This function will run six load tests in sequence and output the results. This function has four input parameters:
	- **RemoteHost** - This parameter is required and is the Remote Host IP Address. This host must be running iPerf3 in server mode.
	- **RemoteHostOS** - This optional parameter signifies the operating system of the REMOTE host. Valid values are "Windows" or "Linux". It is assumed that if the remote host is Linux it is listening on port 22. If Windows PSPing will use the RDP port 3389.
	- **TestSeconds** - This optional parameter signifies the duration of the PSPing test in seconds. It is an integer value (whole number). The range of valid values is 10 - 3600 seconds (10 seconds - 1 hour). The default value is 60 seconds (1 minute).
	- **DetailedOutput** - This optional parameter affects the output of the data results. Normal output consists of the Test Name, Bandwidth, Packet Loss, and the 50th percentile value for latency. With this parameter enabled addition data fields (Count of packets sent for each test, the Minimum, Maximum, Average, 90th, and 95th percentile latency values) are also sent as output. When this option is used I recommend piping to a variable or formatting the output as shown in step 5.
4. For the first run, I recommend doing a test run of 10 seconds (minimum TestSecond value). To do this, in the PowerShell prompt run the following command (where 10.0.0.1 is the private IP address of the remote VM, assuming for this example a Windows remote host):

	```powershell
	Get-LinkPerformance -RemoteHost 10.0.0.1 -TestSeconds 10
	```
5. Future execution of this script can be set for a given duration, for example a 1 hour test (maximum TestSecond value) with a Linux remote host and detailed output (with detailed output I like to format the results as a table, or pipe to a variable):

	```powershell
	Get-LinkPerformance -RemoteHost 10.0.0.1 -TestSeconds 3600 -RemoteHostOS Linux -DetailedOutput | ft
	```
	or
	```powershell
	$myVar = Get-LinkPerformance -RemoteHost 10.0.0.1 -TestSeconds 3600 -RemoteHostOS Linux -DetailedOutput
	$myVar | ft
	```

#### Tool Output

## Link Availability
This collection of server side web pages and local PowerShell that will generate, collect, store, and display availability statistics of the network between you and a newly built Windows VM in Azure. It will do more in the future, but currently only provides availability information.

It is designed to provide an indication, over time, of the link between a Virtual Machine in Azure and an on-premise network. While the focus is on network availability, the test is done from a PC client to an IIS server in Azure. This provides a view into the availability of an end-to-end scenario, not just a single point or component in the complex chain that makes up a VPN or an ExpressRoute network connection. The hope is that this will provide insight into the end-to-end network availability.

![0]

>**Note**: This tool is not certified by Microsoft, nor is it supported by Microsoft support. Download and use at your own risk. While the author is an employee of Microsoft, this tool is provided as my best effort to provide insight into the connectivity between an on-premise network and an Azure endpoint. See the [Support and Legal Disclaimers](#support-and-legal-disclaimers) below for more info.

### Fast Start
If you just want to install the toolkit, this is a the place to start:

1. Create a new Windows Server Azure VM on an ExpressRoute connected VNet
2. On the new Azure VM, in an elevated PowerShell Prompt, run the following command:  **(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Azure/NetworkMonitoring/master/AzureCT/ServerSide/IISBuild.ps1") | Invoke-Expression**
3. On your local PC run the following command from PowerShell: **(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Azure/NetworkMonitoring/master/AzureCT/PowerShell/Install-AzureCT.ps1") | Invoke-Expression**
4. On your local PC you now have the Get-AzureNetworkAvailability command to run availability tests!


### Tool Usage
#### Prerequisites
This tool has three perquisite resources that must be in place before using:

1. An Azure virtual network with a VPN or ExpressRoute site-to-site connection to another (usually "on-premise") network.
2. A newly created Azure Virtual Machine (VM), running Windows Server 2012 or greater, on the Azure VNet that is reachable from the on-premise network. The files and configuration of the Azure VM will be modified, potentially in disruptive ways. To avoid conflicts and/or errors it is important that the Azure VM used is newly built and is a "clean" build, meaning with no other applications or data installed.
3. A client PC (or server) running PowerShell 3.0 or greater on the on-premise network that can reach (via RDP or Remote Desktop) the Azure VM.

#### Installation Instructions
1. Local PC Instructions:
	- Install the AzureCT PowerShell module by running the following command in a PowerShell prompt:

		```powershell
		(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Azure/NetworkMonitoring/master/AzureCT/PowerShell/Install-AzureCT.ps1") | Invoke-Expression
		```
	- This will install a new PowerShell module with eight PowerShell cmdlets; Get-AzureNetworkAvailability, Clear-AzureCTHistory, Show-AzureCTResults, Get-HostName, Get-IPTrace, and Remove-AzureCT, Install-LinkPerformance, and Get-LinkPerformance.
2. Azure VM Instructions:
	- Note the IP Address for this Azure VM that was assigned by the VNet, this will be used many times.
	- Install the web application by running the following command in an elevated PowerShell prompt (ie "Run as Administrator") on the Azure VM.

		```powershell
		(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Azure/NetworkMonitoring/master/AzureCT/ServerSide/IISBuild.ps1") | Invoke-Expression
		```

	- This script will turn on ICMP (ping), install IIS, .Net 4.5, and copy some IIS application files from GitHub. If any errors occur with the file copies, or your server doesn't have access to the Internet, the files can be manually copied. Copy all files from the ServerSide directory of this GitHub to the C:\Inetpub\wwwroot folder on the server. **Note**: If needed, this script can be run multiple times on the server until all errors are resolved. If you manually copy the files, please run the script again to ensure proper file permissions are set on the files.
4. Validate Installation:
	- Go to `http://<IP Copied from Step 2>`; e.g. http://10.0.0.1
	- You should successfully bring up a web page titled "Azure Connectivity Toolkit - Availability Home Page". This validates that the web server was successfully set-up and reachable by the local PC. **Note:** Since the Get-AzureNetworkAvailability script hasn't been run, this web page will just be the framework with no real data in it yet. Don't worry, we're about to generate some data!

> **IMPORTANT**: If warnings are received on either the server or the client regarding ExecutionPolicy in PowerShell, you may need to update your PowerShell settings to allow remote scripts to be run. In PowerShell more information can be found by running "Get-Help about_Execution_Policies" or at this web site: [MSDN][MSDN]
>
> I usually opt for the RemoteSigned setting, but security for your organization should be considered when selecting a new ExecutionPolicy. This can be done by running "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned" from an admin PowerShell prompt. You will only need to change this setting once as it is a persistent global PowerShell setting on each machine.


#### Running the tool
1. On the local Client PC, open a PowerShell prompt.
2. The main cmdlet is Get-AzureNetworkAvailability. This function will make a web call to the remote server once every 10 seconds for the duration of the test. This function has three input parameters:
	- **RemoteHost** - This is required and is the Azure VM IP Address copied in step 2 of the Installation Instructions above.
	- **DurationMinutes** - This optional parameter signifies the duration of the Get-AzureNetworkAvailability command in minutes. It is an integer value (whole number). The default value is 1.
	- **TimeoutSeconds** - This optional parameter signifies how long each call will wait for a response. The default value is 5 seconds.
4. For the first run, I recommend doing a test run of 1 minute (default option). To do this, in the PowerShell prompt run the following command (where 10.0.0.1 is the private IP address of the Azure VM):

	```powershell
	Get-AzureNetworkAvailability -RemoteHost 10.0.0.1
	```
5. Future execution of this script should be set for a given set of minutes, for example a 10 hour test:

	```powershell
	Get-AzureNetworkAvailability -RemoteHost 10.0.0.1 -DurationMinutes 600
	```

>Note: Data from each run of the Get-AzureNetworkAvailability command will uploaded and saved to the Azure VM. If there are errors uploading the data or the command is terminated before uploading, the data is stored locally on the PC until the next successful run of Get-AzureNetworkAvailability. Uploaded data accumulates on the Azure VM and is selectable and displayed using the default IIS page on the Azure VM.

#### Tool Output
Get-AzureNetworkAvailability will issue a call to a web page on the remote server (WebTest.aspx), based on the response (either an error, a timeout, or a successful response) the script will then wait ten seconds and try again. Each call will produce command line output to the PowerShell prompt of one of the following.

>**Possible Script Output**
>
>! (exclamation point) - Successful Call
>
>. (period) - Unsuccessful Call (timeout)
>
>\* (asterisk) - IP was reached and a web server responded, but with unexpected data or an error (e.g. 404)

Each call to the web server is also recorded locally, in the %temp% directory, in two XML files.
-AvailabilityHeader.xml
-AvailabilityDetail.xml

When this command finishes, a summary of the run will be output to the PowerShell prompt similar to ping results.

The XML files are also uploaded to the server and a web browser should open on the local client machine with the details of all Get-AzureNetworkAvailability jobs run against that server. If the Get-AzureNetworkAvailability command was successful, and the data successfully uploaded to the server, the local XML files will be deleted from the local Client PC. If any errors with the job or the data upload, the XML will remain on the local Client PC until a successful Get-AzureNetworkAvailability run at which point all previous data sets will be uploaded and the XML files deleted locally.

Example screen shots can be seen for these conditions:

 - [A Successful one minute run][One Minute]
 - [A successful ten hour run][Ten Hour]
 - [A successful run with errors][Errors]
 - [An unsuccessful run][Timeout]

#### Data Presentation and Review
After running Get-AzureNetworkAvailability, a web page should open on the local PC, displaying the data for all script runs.
The page can be opened at any time by opening a browser and navigating to `http://<Azure VM IP>` e.g. http://10.0.0.1.

The drop down on that page will show all the data sets (by data and time) contained in the servers XML files.

Selecting a specific data set will display the graph and detailed tabular data for that run, as well as the summary information.

#### Other Tool Cmdlets
There are five other commands that can be run:
- Clear-AzureCTHistory
- Show-AzureCTResults
- Get-HostName
- Get-IPTrace
- Remove-AzureCT

Both the Clear-AzureCTHistory and Show-AzureCTResults cmdlets have a single input parameter:
- **RemoteHost** - This parameter is required for Show-AzureCTResults and optional for Clear-AzureCTHistory, for both scripts this parameter is the IP Address of the Azure VM copied in step 2 of the Installation Instructions above.

##### Clear-AzureCTHistory
This function will delete any Get-AzureNetworkAvailability data on both the local PC and the remote Azure VM (if the remote server IP is provided). This command is never required to be run, but can be helpful if there are many entries in the web page drop-down box, a new series of tests is about to be run, or if the XML file size becomes slow rendering in the browser.

##### Show-AzureCTResults
This function will open a web browser on the local Client PC to display the Get-AzureNetworkAvailability data saved to the remote Azure VM.

##### Get-HomeName
This function uses a passed in IP address and does a DNS Host Name look-up using the default DNS look-up setting of the machine it's run on.

##### Get-IPTrace
This function uses a passed in IP address and performs a Trace Route like function. It's output is for the main Get-AzureNetworkAvailability function. To make this more human readable, use the Format-Table option.

```powershell
Get-IPTrace 10.0.0.1 | Format-Table
```

## Removing the Azure Connectivity Toolkit
Once testing is complete the Azure VM should be deleted to avoid unnecessary Azure usage (and associated charges) and all local files can be deleted. There is nothing permanently installed, only the PowerShell module files copied from GitHub and potentially the two XML files in the Local Client PC %temp% directory. 

To ensure 100% removal of all artifacts from this tool perform the following step:

1. Run the Remove-AzureCT command from PowerShell. This will remove the PowerShell module and any local data files.

	```powershell
	Remove-AzureCT
	```

## History

 - 2016-02-03 - Initial beta release 1.6.0.1
 - 2016-02-07 - Updated beta release 1.6.0.2
 - 2016-02-22 - Added more functions and client side trace 1.9.0.1
 - 2017-06-26 - Added bandwidth and latency test related commands

## Incorporated Licenses
This tool incorporates [JQuery](https://jquery.org/license/ "JQuery License") for XML manipulation and is included in the ServerSide files. JQuery.js is included and used under the requirements of the MIT License, and in compliance with the main JQuery license proviso "*You are free to use any jQuery Foundation project in any other project (even commercial projects) as long as the copyright header is left intact.*"

## Support and Legal Disclaimers
Microsoft provides no support for this software. All support, assistance, and information is on this site alone.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; INCREMENTAL AZURE COSTS INCURRED THROUGH USE OF THIS SOFTWARE; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<!--Image References-->
[0]: ./media/AzureCTAvailability.png "AzureCT Availability Test Diagram"
[1]: ./media/AzureCTPerformance.png "AzureCT Performance Test Diagram"

<!--Link References-->
[One Minute]: ./media/RunOneMinute.md
[Ten Hour]: ./media/RunTenHour.md
[Errors]: ./media/RunErrors.md
[Timeout]: ./media/RunTimeout.md
[MSDN]: https://technet.microsoft.com/en-us/library/hh849812.aspx
