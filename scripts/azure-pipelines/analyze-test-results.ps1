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

.PARAMETER failurelogDir
Path to the failure logs that need to be published to azure for inspection.

.PARAMETER outputDir
Where to write out the results of the analysis.

.PARAMETER allResults
Include tests that have no change from the baseline in the output.

.PARAMETER errorOnRegression
Output an error on test regressions.
This will give a clean message in the build pipeline.

.PARAMETER noTable
Don't create or upload the markdown table of results

.PARAMETER triplets
A list of triplets to analyze; defaults to all triplets.

.PARAMETER baselineFile
The path to the ci.baseline.txt file in the vcpkg repository.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$logDir,
    [Parameter(Mandatory = $true)]
    [string]$failurelogDir,
    [Parameter(Mandatory = $true)]
    [string]$outputDir,
    [switch]$allResults,
    [switch]$errorOnRegression,
    [switch]$noTable,
    [string[]]$triplets = @(),
    [Parameter(Mandatory = $true)]
    [string]$baselineFile
)

$ErrorActionPreference = 'Stop'

if ( -not (Test-Path $logDir) ) {
    [System.Console]::Error.WriteLine("Log directory does not exist: $logDir")
    exit
}
if ( -not (Test-Path $outputDir) ) {
    [System.Console]::Error.WriteLine("output directory does not exist: $outputDir")
    exit
}

if ( $triplets.Count -eq 0 ) {
    $triplets = @(
        "x64-linux",
        "x64-osx",
        "arm-uwp",
        "arm64-windows",
        "x64-osx",
        "x64-uwp",
        "x64-windows-static",
        "x64-windows",
        "x86-windows"
    )
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
Takes the combined results object and writes it to an xml file.

.DESCRIPTION
write_xunit_results takes the results object from combine_results, and writes the
results XML file to the correct location for the CI system to pick it up.

.PARAMETER combined_results
The results object from combine_results.
#>
function write_xunit_results {
    [CmdletBinding()]
    Param(
        $combined_results
    )
    $allTests = $combined_results.allTests
    $triplet = $combined_results.collectionName

    $filePath = "$outputDir\$triplet.xml"
    if (Test-Path $filePath) {
        Write-Verbose "removing old file $filepath"
        rm $filePath
    }
    Write-Verbose "output filename: $filepath"

    $xmlWriter = New-Object System.Xml.XmlTextWriter($filePath, $Null)
    $xmlWriter.Formatting = "Indented"
    $xmlWriter.IndentChar = "`t"

    $xmlWriter.WriteStartDocument()
    $xmlWriter.WriteStartElement("assemblies")
    $xmlWriter.WriteStartElement("assembly")
    $xmlWriter.WriteAttributeString("name", $combined_results.assemblyName)
    $xmlWriter.WriteAttributeString("run-date", $combined_results.assemblyStartDate)
    $xmlWriter.WriteAttributeString("run-time", $combined_results.assemblyStartTime)
    $xmlWriter.WriteAttributeString("time", $combined_results.assemblyTime)

    $xmlWriter.WriteStartElement("collection")
    $xmlWriter.WriteAttributeString("name", $triplet)
    $xmlWriter.WriteAttributeString("time", $combined_results.collectionTime)

    foreach ($testName in $allTests.Keys) {
        $test = $allTests[$testName]

        $xmlWriter.WriteStartElement("test")

        $fullTestName = "$($testName):$triplet"
        $xmlWriter.WriteAttributeString("name", $fullTestName)
        $xmlWriter.WriteAttributeString("method", $fullTestName)
        $xmlWriter.WriteAttributeString("time", $test.time)
        $xmlWriter.WriteAttributeString("result", $test.result)

        switch ($test.result) {
            "Pass" { } # Do nothing
            "Fail" {
                $xmlWriter.WriteStartElement("failure")
                $xmlWriter.WriteStartElement("message")
                $xmlWriter.WriteCData($test.message)
                $xmlWriter.WriteEndElement() #message
                $xmlWriter.WriteEndElement() #failure
            }
            "Skip" {
                $xmlWriter.WriteStartElement("reason")
                $xmlWriter.WriteCData($test.message)
                $xmlWriter.WriteEndElement() #reason
            }
        }

        $xmlWriter.WriteEndElement() # test
    }


    $xmlWriter.WriteEndElement() # collection
    $xmlWriter.WriteEndElement() # assembly
    $xmlWriter.WriteEndElement() # assemblies
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()
}

<#
.SYNOPSIS
Saves the failure logs, and prints information to the screen for CI.

.DESCRIPTION
save_failure_logs takes the combined_results object, saves the failure
logs to the correct location for the CI to pick them up, and writes pretty
information to the screen for the CI logs, so that one knows what's wrong.

.PARAMETER combined_results
The results object from combine_results.
#>
function save_failure_logs {
    [CmdletBinding()]
    Param(
        $combined_results
    )
    $triplet = $combined_results.collectionName
    $allTests = $combined_results.allTests

    # abi_tags of missing results (if any exist)
    $missing_results = @()

    foreach ($testName in $allTests.Keys) {
        $test = $allTests[$testName]
        if ($test.result -eq "Fail") {
            $path_to_failure_Logs = Join-Path "$outputDir" "failureLogs"
            if ( -not (Test-Path $path_to_failure_Logs)) {
                mkdir $path_to_failure_Logs | Out-Null
            }
            $path_to_triplet_Logs = Join-Path $path_to_failure_Logs "$triplet"
            if ( -not (Test-Path $path_to_triplet_Logs)) {
                mkdir $path_to_triplet_Logs | Out-Null
            }

            $abi_tag = $test.abi_tag
            $sourceDirectory = Join-Path "$failurelogDir" "$($abi_tag.substring(0,2))"
            $sourceFilename = Join-Path $sourceDirectory "$abi_tag.zip"
            Write-Verbose "searching for $sourceFilename"

            if ( Test-Path $sourceFilename) {
                Write-Verbose "found failure log file"

                Write-Verbose "Uncompressing $sourceFilename to $outputDir\failureLogs\$triplet\"
                Write-Host "Uncompressing $sourceFilename to $outputDir\failureLogs\$triplet\"

                $destination = Join-Path (Join-Path "$outputDir" "failureLogs") "$triplet"

                Expand-Archive -Path $sourceFilename -Destination $destination -Force
            }
            elseif ($test.currentState -eq "Pass") {
                # The port is building, but is marked as expected to fail.  There are no failure logs.
                # Write a log with instructions how to fix it.
                Write-Verbose "The port is building but marked as expected to fail, adding readme.txt with fixit instructions"

                $out_filename = Join-Path (Join-Path (Join-Path (Join-Path "$outputDir" "failureLogs") "$triplet") "$($test.name)") "readme.txt"

                $message = "Congradulations! The port $($test.name) builds for $triplet!`n"
                $message += "For the CI tests to recognize this, please update ci.baseline.txt in your PR.`n"
                $message += "Remove the line that looks like this:`n"
                $message += " $($test.name):$triplet=fail`n"
                $message | Out-File $out_filename -Encoding ascii
            }
            else {
                $missing_results += $test.abi_tag
                Write-Verbose "Missing failure logs for $($test.name)"
                Join-Path (Join-Path (Join-Path "$outputDir" "failureLogs") "$triplet" ) "$($test.name)" | % { mkdir $_ } | Out-Null
            }



            if ((Convert-Path "$outputDir\failureLogs\$triplet\$($test.name)" | Get-ChildItem).count -eq 0) {
                Write-Verbose "The logs are empty, adding readme.txt"

                $readme_path = Join-Path (Join-Path (Join-Path (Join-Path "$outputDir" "failureLogs") "$triplet") "$($test.name)") "readme.txt"

                $message = "There are no build logs for $($test.name) build.`n"
                $message += "This is usually because the build failed early and outside of a task that is logged.`n"
                $message += "See the console output logs from vcpkg for more information on the failure.`n"
                $message += "If the console output of the $($test.name) is missing you can trigger a rebuild`n"
                $message += "in the test system by making any whitespace change to one of the files under`n"
                $message += "the ports/$($test.name) directory or by asking a member of the vcpkg team to remove the`n"
                $message += "tombstone for abi tag $abi_tag`n"
                $message | Out-File $readme_path -Encoding ascii
            }
        }
    }

    if ($missing_results.count -ne 0) {
        $missing_tag_filename = Join-Path (Join-Path (Join-Path "$outputDir" "failureLogs") "$triplet") "missing_abi_tags.txt"
        $missing_results | Out-File -FilePath $missing_tag_filename -Encoding ascii
    }
    Write-Verbose "$triplet logs saved: $(Get-ChildItem $outputDir\failureLogs\$triplet\ -ErrorAction Ignore)"

}

<#
.SYNOPSIS
Writes a pretty summary table to the CI log.

.DESCRIPTION
Takes a hashtable which maps triplets to objects returned by the combine_results
cmdlet, and a list of missing triplets, and prints a really pretty summary table
to the CI logs.

.PARAMETER complete_results
A hashtable which maps triplets to combine_results objects.

.PARAMETER missing_triplets
A list of missing triplets.
#>
function write_summary_table {
    [CmdletBinding()]
    Param(
        $complete_results,
        $missing_triplets
    )

    $table = ""

    foreach ($triplet in $complete_results.Keys) {
        $triplet_results = $complete_results[$triplet]

        if ($triplet_results.allTests.count -eq 0) {
            $table += "$triplet CI build test results are clean`n`n"
        }
        else {
            $portWidth = $triplet.length
            #calculate the width of the first column
            foreach ($testName in $triplet_results.allTests.Keys) {
                $test = $triplet_results.allTests[$testName]
                if ($portWidth -lt $test.name.length) {
                    $portWidth = $test.name.length
                }
            }

            # the header
            $table += "|{0,-$portWidth}|result|features|notes`n" -f $triplet
            $table += "|{0}|----|--------|-----`n" -f ("-" * $portWidth)

            # add each port results
            foreach ($testName in $triplet_results.allTests.Keys | Sort-Object) {
                $test = $triplet_results.allTests[$testName]
                $notes = ""
                if ($test.result -eq 'Fail') {
                    $notes = "**Regression**"
                }
                elseif ($test.result -eq 'Skip') {
                    if ($test.currentResult -eq 'Fail') {
                        $notes = "Previously skipped, not a regression"
                    }
                    else {
                        $notes = "Missing port dependency"
                    }
                }
                $notes = $test.message
                $table += "|{0,-$portWidth}|{1,-4}|{2}|{3}`n" -f $test.name, $test.currentResult, $test.features, $notes
            }
            $table += "`n"
        }
        if ($triplet_results.ignored.Count -ne 0) {
            $table += "The following build failures were ignored: $($triplet_results.ignored)`n"
        }
    }

    # Add list of missing triplets to the table
    foreach ($triplet in $missing_triplets.Keys) {
        $table += "$triplet results are inconclusive because it is missing logs from test run`n`n"
    }

    $table
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
$missing_triplets = @{ }
foreach ( $triplet in $triplets) {
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
}

Write-Verbose "done analizing results"

# If there is only one triplet, add the triplet name to the result table file
if ($triplets.Count -eq 1) {
    $result_table_name = $triplets[0]
}
else {
    $result_table_name = ""
}

if (-not $noTable) {
    $table_path = Join-Path "$outputDir" "result_table$result_table_name.md"

    write_summary_table -complete_results $complete_results -missing_triplets $missing_triplets | Out-File -FilePath $table_path -Encoding ascii

    Write-Host ""
    cat $table_path

    Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=$result_table_name issue summary;]$table_path"
}

foreach ( $triplet in $complete_results.Keys) {
    $combined_results = $complete_results[$triplet]
    if ( $failurelogDir -ne "") {
        save_failure_logs -combined_results $combined_results
    }

    write_xunit_results -combined_results $combined_results
}


# emit error last.  Unlike the table output this is going to be seen in the "status" section of the pipeline
# and needs to be formatted for a single line.
if ($errorOnRegression) {
    write_errors_for_summary -complete_results $complete_results

    if ($missing_triplets.Count -ne 0) {
        $regression_log_directory = Join-Path "$outputDir" "failureLogs"
        if ( -not (Test-Path $regression_log_directory)) {
            mkdir $regression_log_directory | Out-Null
        }
        $file_path = Join-Path $regression_log_directory "missing_test_results.txt"
        $message = "Test logs are missing for the following triplets: $($hash.Keys | %{"$($_)($($hash[$_]))"})`n"
        $message += "Without this information the we are unable to determine if the build has regressions. `n"
        $message += "Missing test logs are sometimes the result of failures in the pipeline infrastructure. `n"
        $message += "If you beleave this is the case please alert a member of the vcpkg team to investigate. `n"
        $message | Out-File $file_path -Encoding ascii
    }
}
