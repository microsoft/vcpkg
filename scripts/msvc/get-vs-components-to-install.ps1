function Get-Components-To-Install {
    param (
        [Parameter(Mandatory = $true)]
        [array]$RequestedComponents,

        [Parameter(Mandatory = $true)]
        [array]$Packages
    )

    $searchList = $RequestedComponents | ForEach-Object { $_.ToLower() }
    $foundList = @()
    $notFound = @{}
    $newDeps = @{}
    $skippedDeps = @()
    $payloads = @()
    $payloadsOtherLang = @()
    $strangeDeps = @()
    $depsList = @()

    while ($searchList.Count -gt 0) {
        $current_payloads =  $Packages | Where-Object {
            $searchList.toLower() -contains $_.id.toLower()
        }

        $current_payloads_ids = $current_payloads | ForEach-Object { $_.id } | Select-Object -Unique
        $foundList += $current_payloads_ids

        $notFound = $searchList | Where-Object { -not ($current_payloads_ids.toLower() -contains $_.toLower()) }

        if ($notFound.Count -ne 0) {
            Write-Host "The following components have not been found:"
            Write-Host "$notFound"
        }

        $deps = ($current_payloads.dependencies)
        $depsList = $deps | ForEach-Object {
            $propertyNames = $_.PSObject.Properties.Name
            $object = $_        
            $propertyNames | ForEach-Object { 
                $innerObject = $object.$_
                if ( [bool]($innerObject.PSobject.Properties.name -match "type") ) {
                    return
                } elseif ( [bool]($innerObject.PSobject.Properties.name -match "id") ) {
                    $innerObject.id
                } else {
                    $_
                }
            }
        } | Select-Object -Unique

        if ( $current_payloads -is [hashtable] ) {
            Write-Error "Payload array $current_payloads is a hashtable!"
        }

        $filtered_payloads = $current_payloads | ForEach-Object {
            #Write-Host $_
            $names = $_.PSobject.Properties.name
            $hasPayloads = $names -contains "payloads"
            $hasLanguage = $names -contains "language"
            $hasDeps = $names -contains "dependencies"
            $hasMachineArch =  $names -contains "machineArch"
            $hasProductArch =  $names -contains "productArch"
            if($hasLanguage) {
                $hasRelevantLanguage = ($_.language.toLower() -eq 'en-us' -or $_.language.toLower() -eq 'neutral')
                if(-not $hasRelevantLanguage) {
                    return
                }
            }
            if($hasMachineArch) {
                $arch = $_.machineArch.toLower()
                if($_.machineArch.toLower() -ne 'x64' -and $_.machineArch.toLower() -ne 'neutral') {
                    return
                }
            }
            if($hasProductArch) {
                $arch = $_.productArch.toLower()
                if($_.productArch.toLower() -ne 'x64' -and $_.productArch.toLower() -ne 'neutral') {
                    return
                }
            }

            if ($hasPayloads -and -not $hasLanguage) {
                $_
            } elseif ($hasPayloads -and $hasLanguage -and $hasRelevantLanguage) {
                $_
            } elseif (-not $hasPayloads -and -not $hasDeps) {
                $strangeDeps += $_
                return
            } else {
                return
            }            
        }

        $payloads += $filtered_payloads

        $newDeps = $depsList | Where-Object { $_.toLower() -notin $searchList.toLower() -or $_.toLower() -notin $foundList.toLower()}
        $searchList = $newDeps
    }

    $payloads = $payloads | Select-Object -Unique *
    Write-Host "Finished analyzing components"
    return $payloads
}
