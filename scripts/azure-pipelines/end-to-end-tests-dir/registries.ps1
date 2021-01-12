. "$PSScriptRoot/../end-to-end-tests-prelude.ps1"


$builtinRegistryArgs = $commonArgs + @("--x-builtin-port-versions-dir=$PSScriptRoot/../../e2e_ports/port_versions")

Run-Vcpkg install @builtinRegistryArgs 'vcpkg-internal-e2e-test-port'
Throw-IfNotFailed

Run-Vcpkg install @builtinRegistryArgs --feature-flags=registries 'vcpkg-internal-e2e-test-port'
Throw-IfFailed

Run-Vcpkg install @builtinRegistryArgs --feature-flags=registries 'zlib'
Throw-IfFailed

# Test git and filesystem registries
Refresh-TestRoot
$filesystemRegistry = "$TestingRoot/filesystem-registry"
$gitRegistryUpstream = "$TestingRoot/git-registry-upstream"

# build a filesystem registry
New-Item -Path $filesystemRegistry -ItemType Directory
$filesystemRegistry = (Get-Item $filesystemRegistry).FullName

Copy-Item `
    -LiteralPath "$PSScriptRoot/../../e2e_ports/port_versions/baseline.json" `
    -Destination "$filesystemRegistry/baseline.json"
Copy-Item -Recurse `
    -LiteralPath "$PSScriptRoot/../../e2e_ports/vcpkg-internal-e2e-test-port" `
    -Destination "$filesystemRegistry"
New-Item `
    -Path "$filesystemRegistry/port_versions" `
    -ItemType Directory
New-Item `
    -Path "$filesystemRegistry/port_versions/v-" `
    -ItemType Directory

$vcpkgInternalE2eTestPortJson = @{
    "versions" = @(
        @{
            "version-string" = "1.0.0";
            "path" = "$/vcpkg-internal-e2e-test-port"
        }
    )
}
New-Item `
    -Path "$filesystemRegistry/port_versions/v-/vcpkg-internal-e2e-test-port.json" `
    -ItemType File `
    -Value (ConvertTo-Json -Depth 5 -InputObject $vcpkgInternalE2eTestPortJson)


# build a git registry
New-Item -Path $gitRegistryUpstream -ItemType Directory
$gitRegistryUpstream = (Get-Item $gitRegistryUpstream).FullName

Push-Location $gitRegistryUpstream
try
{
    $CurrentTest = 'git init .'
    git init .
    Throw-IfFailed
    $CurrentTest = 'git config'
    git config --local user.name 'Nobody'
    Throw-IfFailed
    git config --local user.email 'nobody@example.com'
    Throw-IfFailed
    git config --local core.autocrlf 'false'
    Throw-IfFailed
    Copy-Item -Recurse -LiteralPath "$PSScriptRoot/../../e2e_ports/port_versions" -Destination .
    Copy-Item -Recurse -LiteralPath "$PSScriptRoot/../../e2e_ports/vcpkg-internal-e2e-test-port" -Destination .

    $CurrentTest = 'git add .'
    git add .
    Throw-IfFailed
    $CurrentTest = 'git commit'
    git commit -m 'initial commit'
    Throw-IfFailed
}
finally
{
    Pop-Location
}

# actually test the registries

# test the filesystem registry
$manifestDir = "$TestingRoot/filesystem-registry-test-manifest-dir"

New-Item -Path $manifestDir -ItemType Directory
$manifestDir = (Get-Item $manifestDir).FullName

Push-Location $manifestDir
try
{
    $vcpkgJson = @{
        "name" = "manifest-test";
        "version-string" = "1.0.0";
        "dependencies" = @(
            "vcpkg-internal-e2e-test-port"
        )
    }
    New-Item -Path 'vcpkg.json' -ItemType File `
        -Value (ConvertTo-Json -Depth 5 -InputObject $vcpkgJson)

    $vcpkgConfigurationJson = @{
        "default-registry" = $null;
        "registries" = @(
            @{
                "kind" = "filesystem";
                "path" = $filesystemRegistry;
                "packages" = @( "vcpkg-internal-e2e-test-port" )
            }
        )
    }
    New-Item -Path 'vcpkg-configuration.json' -ItemType File `
        -Value (ConvertTo-Json -Depth 5 -InputObject $vcpkgConfigurationJson)

    Run-Vcpkg install @commonArgs '--feature-flags=registries,manifests'
    Throw-IfFailed
}
finally
{
    Pop-Location
}

# test the git registry
$manifestDir = "$TestingRoot/git-registry-test-manifest-dir"

New-Item -Path $manifestDir -ItemType Directory
$manifestDir = (Get-Item $manifestDir).FullName

Push-Location $manifestDir
try
{
    $vcpkgJson = @{
        "name" = "manifest-test";
        "version-string" = "1.0.0";
        "dependencies" = @(
            "vcpkg-internal-e2e-test-port"
        )
    }
    New-Item -Path 'vcpkg.json' -ItemType File `
        -Value (ConvertTo-Json -Depth 5 -InputObject $vcpkgJson)

    $vcpkgConfigurationJson = @{
        "default-registry" = $null;
        "registries" = @(
            @{
                "kind" = "git";
                "repository" = $gitRegistryUpstream;
                "packages" = @( "vcpkg-internal-e2e-test-port" )
            }
        )
    }
    New-Item -Path 'vcpkg-configuration.json' -ItemType File `
        -Value (ConvertTo-Json -Depth 5 -InputObject $vcpkgConfigurationJson)

    Run-Vcpkg install @commonArgs '--feature-flags=registries,manifests'
    Throw-IfFailed
}
finally
{
    Pop-Location
}
