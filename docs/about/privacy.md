
# Privacy and Vcpkg

## Do you collect telemetry data? What is it used for?

We do collect telemetry data from usage of "vcpkg.exe". We explicitly ONLY collect information from invocations of the tool itself; we do NOT add any tracking information into the produced libraries. We use this information to understand usage issues, such as failing packages, and to guide tool improvements.

## What telemetry is collected?

We collect the command line used, the time of invocation, and how long execution took. Some commands also add additional calculated information (such as the full set of libraries to install). We generate a completely random UUID on first use and attach it to each event.
In order to opt-out of data collection, you can re-run the boostrap script with the following flag, for Windows and Linux/OSX, respectively:

```PS> .\bootstrap-vcpkg.bat -disableMetrics```

```~/$ ./bootstrap-vcpkg.sh -disableMetrics```

For more information about how Microsoft protects your privacy, see https://privacy.microsoft.com/en-us/privacy.

Here is an example of an event for the command line `vcpkg install zlib`:
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

## Is the data stored on my system?

We store each event document in your temporary files directory. These will be cleaned out whenever you clear your temporary files.
