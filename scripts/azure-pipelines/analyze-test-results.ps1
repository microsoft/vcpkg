# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Analyze the test results as output by the CI system.

.DESCRIPTION
Takes the set of port test results from $logDir,
and the baseline from $baselineFile, and makes certain that the set
of failures we expected are exactly the set of failures we got.
Then, uploads the logs from any unexpected failures.

.PARAMETER logDir
Directory of xml test logs to analyze.

.PARAMETER allResults
Include tests that have no change from the baseline in the output.

.PARAMETER triplet
The triplet to analyze.

.PARAMETER baselineFile
The path to the ci.baseline.txt file in the vcpkg repository.

.PARAMETER passingIsPassing
Indicates that 'Passing, remove from fail list' results should not be emitted as failures. (For example, this is used
when using vcpkg to test a prerelease MSVC++ compiler)
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$logDir,
    [switch]$allResults,
    [Parameter(Mandatory = $true)]
    [string]$triplet,
    [Parameter(Mandatory = $true)]
    [string]$baselineFile,
    [switch]$passingIsPassing = $false
)

$ErrorActionPreference = 'Stop'

if ( -not (Test-Path $logDir) ) {
    [System.Console]::Error.WriteLine("Log directory does not exist: $logDir")
    exit
}

<#
.SYNOPSIS
Creates an object the represents the test run.

.DESCRIPTION
build_test_results takes an XML file of results from the CI run,
and constructs an object based on that XML file for further
processing.

.OUTPUTS
An object with the following elements:
    assemblyName:
    assemblyStartDate:
    assemblyStartTime:
    assemblyTime:
    collectionName:
    collectionTime:
    allTests: A hashtable with an entry for each port tested
        The key is the name of the port
        The value is an object with the following elements:
            name: Name of the port (Does not include the triplet name)
            result: Pass/Fail/Skip result from xunit
            time: Test time in seconds
            originalResult: Result as defined by Build.h in vcpkg source code
            abi_tag: The port hash
            features: The features installed

.PARAMETER xmlFilename
The path to the XML file to parse.
#>
function build_test_results {
    [CmdletBinding()]
    Param
    (
        [string]$xmlFilename
    )
    if ( ($xmlFilename.Length -eq 0) -or ( -not( Test-Path $xmlFilename))) {
        #write-error "Missing file: $xmlFilename"
        return $null
    }

    Write-Verbose "building test hash for $xmlFilename"

    [xml]$xmlContents = Get-Content $xmlFilename

    # This currently only supports one collection per assembly, which is the way
    # the vcpkg tests are designed to run in the pipeline.
    $xmlAssembly = $xmlContents.assemblies.assembly
    $assemblyName = $xmlAssembly.name
    $assemblyStartDate = $xmlAssembly."run-date"
    $assemblyStartTime = $xmlAssembly."run-time"
    $assemblyTime = $xmlAssembly.time
    $xmlCollection = $xmlAssembly.collection
    $collectionName = $xmlCollection.name
    $collectionTime = $xmlCollection.time

    $allTestResults = @{ }
    foreach ( $test in $xmlCollection.test) {
        if (!$test.name.endswith(":$triplet"))
        {
            continue
        }
        $name = ($test.name -replace ":.*$")

        # Reconstruct the original BuildResult enumeration (defined in Build.h)
        #   failure.message - why the test failed (valid only on test failure)
        #   reason - why the test was skipped (valid only when the test is skipped)
        #    case BuildResult::POST_BUILD_CHECKS_FAILED:
        #    case BuildResult::FILE_CONFLICTS:
        #    case BuildResult::BUILD_FAILED:
        #    case BuildResult::EXCLUDED:
        #    case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES:
        $originalResult = "NULLVALUE"
        switch ($test.result) {
            "Skip" {
                $originalResult = $test.reason.InnerText
            }
            "Fail" {
                $originalResult = $test.failure.message.InnerText
            }
            "Pass" {
                $originalResult = "SUCCEEDED"
            }
        }

        $abi_tag = ""
        $features = ""
        foreach ( $trait in $test.traits.trait) {
            switch ( $trait.name ) {
                "abi_tag" { $abi_tag = $trait.value }
                "features" { $features = $trait.value }
            }
        }

        # If additional fields get saved in the XML, then they should be added to this hash
        # also consider using a PSCustomObject here instead of a hash
        $testHash = @{ name = $name; result = $test.result; time = $test.time; originalResult = $originalResult; abi_tag = $abi_tag; features = $features }
        $allTestResults[$name] = $testHash
    }

    return @{
        assemblyName      = $assemblyName;
        assemblyStartDate = $assemblyStartDate;
        assemblyStartTime = $assemblyStartTime;
        assemblyTime      = $assemblyTime;
        collectionName    = $collectionName;
        collectionTime    = $collectionTime;
        allTests          = $allTestResults
    }
}

<#
.SYNOPSIS
Creates an object that represents the baseline expectations.

.DESCRIPTION
build_baseline_results converts the baseline file to an object representing
the expectations set up by the baseline file. It records four states:
    1) fail
    2) skip
    3) ignore
    4) pass -- this is represented by not being recorded
In other words, if a port is not contained in the object returned by this
cmdlet, expect it to pass.

.OUTPUTS
An object containing the following fields:
    collectionName: the triplet
    fail: ports marked as fail
    skip: ports marked as skipped
    ignore: ports marked as ignore

.PARAMETER baselineFile
The path to vcpkg's ci.baseline.txt.

.PARAMETER triplet
The triplet to create the result object for.
#>
function build_baseline_results {
    [CmdletBinding()]
    Param(
        $baselineFile,
        $triplet
    )
    #read in the file, strip out comments and blank lines and spaces, leave only the current triplet
    #remove comments, remove empty lines, remove whitespace, then keep only those lines for $triplet
    $baseline_list_raw = Get-Content -Path $baselineFile `
        | Where-Object { -not ($_ -match "\s*#") } `
        | Where-Object { -not ( $_ -match "^\s*$") } `
        | ForEach-Object { $_ -replace "\s" } `
        | Where-Object { $_ -match ":$triplet=" }

    #filter to skipped and trim the triplet
    $skip_hash = @{ }
    foreach ( $port in $baseline_list_raw | ? { $_ -match "=skip$" } | % { $_ -replace ":.*$" }) {
        if ($skip_hash[$port] -ne $null) {
            [System.Console]::Error.WriteLine("$($port):$($triplet) has multiple definitions in $baselineFile")
        }
        $skip_hash[$port] = $true
    }
    $fail_hash = @{ }
    $baseline_list_raw | ? { $_ -match "=fail$" } | % { $_ -replace ":.*$" } | ? { $fail_hash[$_] = $true } | Out-Null
    $ignore_hash = @{ }
    $baseline_list_raw | ? { $_ -match "=ignore$" } | % { $_ -replace ":.*$" } | ? { $ignore_hash[$_] = $true } | Out-Null

    return @{
        collectionName = $triplet;
        skip           = $skip_hash;
        fail           = $fail_hash;
        ignore         = $ignore_hash
    }
}

<#
.SYNOPSIS
Analyzes the results of the current run against the baseline.

.DESCRIPTION
combine_results compares the results to the baselie, and generates the results
for the CI -- whether it should pass or fail.

.OUTPUTS
An object containing the following:
(Note that this is not the same data structure as build_test_results)
    assemblyName:
    assemblyStartDate:
    assemblyStartTime:
    assemblyTime:
    collectionName:
    collectionTime:
    allTests: A hashtable of each port with a different status from the baseline
        The key is the name of the port
        The value is an object with the following data members:
            name: The name of the port
            result: xunit test result Pass/Fail/Skip
            message: Human readable message describing the test result
            time: time the current test results took to run.
            baselineResult:
            currentResult:
            features:
    ignored: list of ignored tests

.PARAMETER baseline
The baseline object to use from build_baseline_results.

.PARAMETER current
The results object to use from build_test_results.
#>
function combine_results {
    [CmdletBinding()]
    Param
    (
        $baseline,
        $current
    )

    if ($baseline.collectionName -ne $current.collectionName) {
        Write-Warning "Comparing mismatched collections $($baseline.collectionName) and $($current.collectionName)"
    }

    $currentTests = $current.allTests

    # lookup table with the results of all of the tests
    $allTestResults = @{ }

    $ignoredList = @()

    Write-Verbose "analyzing $($currentTests.count) tests"

    foreach ($key in $currentTests.keys) {
        Write-Verbose "analyzing $key"

        $message = $null
        $result = $null
        $time = $null
        $currentResult = $null
        $features = $currentTest.features

        $baselineResult = "Pass"
        if ($baseline.fail[$key] -ne $null) {
            Write-Verbose "$key is failing"
            $baselineResult = "Fail"
        }
        elseif ( $baseline.skip[$key] -ne $null) {
            Write-Verbose "$key is skipped"
            $baselineResult = "Skip"
        }
        elseif ( $baseline.ignore[$key] -ne $null) {
            $baselineResult = "ignore"
        }

        $currentTest = $currentTests[$key]

        if ( $currentTest.result -eq $baselineResult) {
            Write-Verbose "$key has no change from baseline"
            $currentResult = $currentTest.result
            if ($allResults) {
                # Only marking regressions as failures but keep the skipped status
                if ($currentResult -eq "Skip") {
                    $result = "Skip"
                }
                else {
                    $result = "Pass"
                }
                $message = "No change from baseline"
                $time = $currentTest.time
            }
        }
        elseif ( $baselineResult -eq "ignore") {
            if ( $currentTest.result -eq "Fail" ) {
                Write-Verbose "ignoring failure on $key"
                $ignoredList += $key
            }
        }
        else {
            Write-Verbose "$key had a change from the baseline"

            $currentResult = $currentTest.result
            # Test exists in both test runs but does not match.  Determine if this is a regression
            # Pass -> Fail = Fail (Regression)
            # Pass -> Skip = Skip
            # Fail -> Pass = Fail (need to update baseline)
            # Fail -> Skip = Skip
            # Skip -> Fail = Fail (Should not happen)
            # Skip -> Pass = Fail (should not happen)

            $lookupTable = @{
                'Pass' = @{
                    'Fail' = @('Fail', "Test passes in baseline but fails in current run. If expected update ci.baseline.txt with '$($key):$($current.collectionName)=fail'");
                    'Skip' = @($null, 'Test was skipped due to missing dependencies')
                };
                'Fail' = @{
                    'Pass' = @('Fail', "Test fails in baseline but now passes.  Update ci.baseline.txt with '$($key):$($current.collectionName)=pass'");
                    'Skip' = @($null, 'Test fails in baseline but is skipped in current run')
                };
                'Skip' = @{
                    'Fail' = @('Skip', "Test is skipped in baseline but fails in current run. Results are ignored")
                    'Pass' = @('Skip', "Test is skipped in baseline but passes in current run. Results are ignored")
                }
            }
            $resultList = $lookupTable[$baselineResult][$currentResult]
            $result = $resultList[0]
            $message = $resultList[1]
            $time = $currentTest.time
            Write-Verbose ">$key $message"
        }

        if ($result -ne $null) {
            Write-Verbose "Adding $key to result list"
            $allTestResults[$key] = @{ name = $key; result = $result; message = $message; time = $time; abi_tag = $currentTest.abi_tag; baselineResult = $baselineResult; currentResult = $currentResult; features = $features }
        }
    }

    return @{
        assemblyName      = $current.assemblyName;
        assemblyStartDate = $current.assemblyStartDate;
        assemblyStartTime = $current.assemblyStartTime;
        assemblyTime      = $current.assemblyTime;
        collectionName    = $current.collectionName;
        collectionTime    = $current.collectionTime;
        allTests          = $allTestResults;
        ignored           = $ignoredList
    }
}

<#
.SYNOPSIS
Writes short errors to the CI logs.

.DESCRIPTION
write_errors_for_summary takes a hashtable from triplets to combine_results
objects, and writes short errors to the CI logs.

.PARAMETER complete_results
A hashtable from triplets to combine_results objects.
#>
function write_errors_for_summary {
    [CmdletBinding()]
    Param(
        $complete_results
    )

    $failure_found = $false

    Write-Verbose "preparing error output for Azure Devops"

    foreach ($triplet in $complete_results.Keys) {
        $triplet_results = $complete_results[$triplet]

        Write-Verbose "searching $triplet triplet"

        # add each port results
        foreach ($testName in $triplet_results.allTests.Keys) {
            $test = $triplet_results.allTests[$testName]

            Write-Verbose "checking $($testName):$triplet $($test.result)"

            if ($test.result -eq 'Fail') {
                if (($test.currentResult) -eq "pass" -and $passingIsPassing) {
                    continue;
                }

                $failure_found = $true
                if ($test.currentResult -eq "pass") {
                    [System.Console]::Error.WriteLine( `
                            "PASSING, REMOVE FROM FAIL LIST: $($test.name):$triplet ($baselineFile)" `
                    )
                }
                else {
                    [System.Console]::Error.WriteLine( `
                            "REGRESSION: $($test.name):$triplet. If expected, add $($test.name):$triplet=fail to $baselineFile." `
                    )
                }
            }
        }
    }
}


$complete_results = @{ }
Write-Verbose "looking for $triplet logs"

# The standard name for logs is:
#   <triplet>.xml
# for example:
#   x64-linux.xml

$current_test_hash = build_test_results( Convert-Path "$logDir\$($triplet).xml" )
$baseline_results = build_baseline_results -baselineFile $baselineFile -triplet $triplet

if ($current_test_hash -eq $null) {
    [System.Console]::Error.WriteLine("Missing $triplet test results in current test run")
    $missing_triplets[$triplet] = "test"
}
else {
    Write-Verbose "combining results..."
    $complete_results[$triplet] = combine_results -baseline $baseline_results -current $current_test_hash
}

Write-Verbose "done analyzing results"

# emit error last.  Unlike the table output this is going to be seen in the "status" section of the pipeline
# and needs to be formatted for a single line.
write_errors_for_summary -complete_results $complete_results
