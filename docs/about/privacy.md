## vcpkg telemetry and privacy

vcpkg collects telemetry data to understand usage issues, such as failing packages, and to guide tool improvements. The collected data is anonymous.
For more information about how Microsoft protects your privacy, see https://privacy.microsoft.com/en-US/privacystatement#mainenterprisedeveloperproductsmodule 

# Scope

We explicitly ONLY collect information from invocations of the tool itself; we do NOT add any tracking information into the produced libraries. Telemetry is collected when using any of the `vcpkg` commands, such as:

```
vcpkg install
vcpkg build
```

# How to opt out

The vcpkg telemetry feature is enabled by default. In order to opt-out of data collection, you can re-run the boostrap script with the following flag, for Windows and Linux/OSX, respectively:

```PS> .\bootstrap-vcpkg.bat -disableMetrics```

```~/$ ./bootstrap-vcpkg.sh -disableMetrics```

# Disclosure

vcpkg displays text similar to the following when you build vcpkg. This is how Microsoft notifies you about data collection.

```
Telemetry
---------
vcpkg collects usage data in order to help us improve your experience. The data collected by Microsoft is anonymous. You can opt-out of telemetry by adding -disableMetrics after the bootstrap-vcpkg script.

Read more about vcpkg telemetry at docs/about/privacy.md
```

# Data Collected

The telemetry feature doesn't collect personal data, such as usernames or email addresses. It doesn't scan your code and doesn't extract project-level data, such as name, repository, or author. The data is sent securely to Microsoft servers and held under restricted access.

Protecting your privacy is important to us. If you suspect the telemetry is collecting sensitive data or the data is being insecurely or inappropriately handled, file an issue in the Microsoft/vcpkg repository or send an email to vcpkg@microsoft.com for investigation.

We collect various telemetry events such as the command line used, the time of invocation, and how long execution took. Some commands also add additional calculated information (such as the full set of libraries to install). We generate a completely random UUID on first use and attach it to each event.

Here is an example of an event for the command line `vcpkg install zlib`. You can see the telemetry events any command by appending `--printmetrics` after the vcpkg command line.
```json
[{
    "ver": 1,
    "name": "Microsoft.ApplicationInsights.Event",
    "time": "2016-09-01T00:19:10.949Z",
    "sampleRate": 100.000000,
    "seq": "0:0",
    "iKey": "aaaaaaaa-4393-4dd9-ab8e-97e8fe6d7603",
    "flags": 0.000000,
    "tags": {
        "ai.device.os": "Windows",
        "ai.device.osVersion": "10.0.14912",
        "ai.session.id": "aaaaaaaa-7c69-4b83-7d82-8a4198d7e88d",
        "ai.user.id": "aaaaaaaa-c9ab-4bf5-0847-a3455f539754",
        "ai.user.accountAcquisitionDate": "2016-08-20T00:38:09.860Z"
    },
    "data": {
        "baseType": "EventData",
        "baseData": {
            "ver": 2,
            "name": "commandline_test7",
            "properties": { "version":"0.0.30-9b4e44a693459c0a618f370681f837de6dd95a30","cmdline":"install zlib","command":"install","installplan":"zlib:x86-windows" },
            "measurements": { "elapsed_us":68064.355736 }
        }
    }
}]
```
In the source code (included in `toolsrc\`), you can search for calls to the functions `TrackProperty()` and `TrackMetric()` to see every specific data point we collect.

# Avoid inadvertent disclosure information 

vcpkg contributors and anyone else running a version of vcpkg that they built themselves should consider the path to their source code. If a crash occurs when using vcpkg, the file path from the build machine is collected as part of the stack trace and isn't hashed.
Because of this, builds of vcpkg shouldn't be located in directories whose path names expose personal or sensitive information.