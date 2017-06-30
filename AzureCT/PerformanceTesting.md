# Azure Connectivity Toolkit (AzureCT)

## Link Performance
This collection of PowerShell commandlets will download required files to run the Get-LinkPerformance command which runs a series of iPerf load tests and PSPing TCP pings concurrently between a local source and a remote host running iPerf3 in server mode. Six tests of increasing load are performed and results are output at the conclusion of the test.

![1]

>**Note**: This tool is not certified by Microsoft, nor is it supported by Microsoft support. Download and use at your own risk. While the author is an employee of Microsoft, this tool is provided as my best effort to provide insight into the connectivity between an on-premise network and an Azure endpoint. See the [Support and Legal Disclaimers](#support-and-legal-disclaimers) below for more info.

### Fast Start
If you just want to install the toolkit, this is the place to start:

1. Install [iPerf3][iPerf] on a host (Linux or Windows) on the "far end" or remote side of the network link you're testing. If the remote host is a Window machine you can install the AzureCT and run the Install command mentioned below to install and configure iPerf. If there is a host firewall ensure port 5201 is open to allow iPerf to run.
2. On the local "near end" host run the following command from PowerShell to install the AzureCT PowerShell module:

	```powershell	
	(new-object Net.WebClient).DownloadString("https://aka.ms/AzureCT") | Invoke-Expression
	```

3. Run the Install-LinkPerformance command, this will download PSPing and iPerf as well as configure your windows firewall to allow ICMP and iPerf.
4. On your local host you now have the Get-LinkPerformance command to run availability tests!

### Tool Usage
The Get-LinkPerformance command will run a series of iPerf load tests and PSPing TCP pings concurrently between a local source and a remote host running iPerf3 in server mode. Six tests of increasing load are performed and results are output at the conclusion of the test.

The remote server must be running iPerf3 in server mode; e.g iPerf3 -s

On the local machine from which Get-LinkPerformance is executed, various parameters can be used to affect the testing. The output is a combination of both the load test and the latency test while the performance test is running.

Each row of output represents the summation of a given test, the follow test conditions are run:
- No load, a PSPing TCP test without iPerf3 running, a pure TCP latency test
- 1 Session, a PSPing TCP test with iPerf3 running a single thread of load
- 6 Sessions, a PSPing TCP test with iPerf3 running a six thread load test
- 16 Sessions, a PSPing TCP test with iPerf3 running a 16 thread load test
- 16 Sessions with 1 Mb window, a PSPing TCP test with iPerf3 running a 16 thread load test with a 1 Mb window
- 32 Sessions, a PSPing TCP test with iPerf3 running a 32 thread load test

For each test iPerf is started and allowed to run for 10 seconds to establish the load and allow it to level. PSPing is then started to record latency during the load test.

Results from each test are stored in a text file in the AzureCT Tools directory (C:\ACTTools)

Output for each test is displayed in a table formatted object with the following columns:

- Name: The name of the test for these values, e.g. No load, 1 session, etc
- Bandwidth: The average bandwidth achieved by iPerf for the given test
- Loss: percentage of packets lost during the PSPing test
- P50 Latency: the 50th percentile of latency seen during the test (median)

If the Detailed Output option (-DetailedOutput) is used the following columns are also output in a list format:

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
		(new-object Net.WebClient).DownloadString("https://aka.ms/AzureCT") | Invoke-Expression
		```

	- This will install a new PowerShell module with eight PowerShell cmdlets; Get-AzureNetworkAvailability, Clear-AzureCTHistory, Show-AzureCTResults, Get-HostName, Get-IPTrace, Remove-AzureCT, Install-LinkPerformance, and Get-LinkPerformance.
	- Run the Install-LinkPerformance command to download iPerf and PSPing as well as set the firewall rules. Note: The -Force option can be used for unattended installations.
2. Remote Host Instructions
	- Note: If the remote host is Windows, you can install the AzureCT module as in step one above and then run the Install-LinkPerformance command to install and configure iPerf.
	- Install iPerf3: [http://iperf.fr][iPerf]
	- Start iPerf3 in server mode (e.g. "iPerf3 -s")
	- Open firewall port 5201 (default iPerf3 port)
	- Ensure host is listening on the admin port (3389 for windows or 22 or Linux)

#### Running the Tool
1. On the local host, open a PowerShell prompt.
2. Run the "Get-Module" command to see if AzureCT is loaded, if not run "Import-Module AzureCT" to load the module.
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
5. Future executions of this script can be set for a given duration, for example a 1 hour test (maximum TestSecond value) with a Linux remote host and detailed output (with detailed output I like to format the results as a table, or pipe to a variable):

	```powershell
	Get-LinkPerformance -RemoteHost 10.0.0.1 -TestSeconds 3600 -RemoteHostOS Linux -DetailedOutput | ft
	```
	or
	```powershell
	$myResults = Get-LinkPerformance -RemoteHost 10.0.0.1 -TestSeconds 3600 -RemoteHostOS Linux -DetailedOutput
	$myResults | ft
	```

#### Tool Output
While the test is running, the progress of each test run (Stage) will be displayed, and the text of which rest run is currently executing will be displayed in the command prompt.

Once all testing is completed, a table formatted matrix of the test results will be output (the results will be list formatted if the -DetailedOutput option is used).

These results can be read directly at the command prompt or piped into another command or variable.

Also, the detailed test results data are stored in text files in the C:\ACTTools directory.

## Removing the Azure Connectivity Toolkit
Once testing is complete the Azure VM can be deleted to avoid unnecessary Azure usage (and associated charges) and all local files can be deleted. The only files on the local machine are the PowerShell module files copied from GitHub, iPerf and PSPPing files in the C:\ACTTools directory (if Install-LinkPerformance was run), and potentially three XML files (if Get-AzureNetworkAvailability was run) in the Local Client PC %temp% directory.

To ensure 100% removal of all artifacts from this tool perform the following step:

1. Run the Remove-AzureCT command from PowerShell. This will remove the PowerShell module and any local data files.

	```powershell
	Remove-AzureCT
	```
## Incorporated Licenses
This tool incorporates [JQuery](https://jquery.org/license/ "JQuery License") for XML manipulation and is included in the ServerSide files. JQuery.js is included and used under the requirements of the MIT License, and in compliance with the main JQuery license proviso "*You are free to use any jQuery Foundation project in any other project (even commercial projects) as long as the copyright header is left intact.*"

## Support and Legal Disclaimers
Microsoft provides no support for this software. All support, assistance, and information is on this site alone.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; INCREMENTAL AZURE COSTS INCURRED THROUGH USE OF THIS SOFTWARE; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<!--Image References-->
[0]: ./media/AzureCTAvailability.png "AzureCT Availability Test Diagram"
[1]: ./media/AzureCTPerformance.png "AzureCT Performance Test Diagram"

<!--Link References-->
[iPerf] http://iPerf.fr
