@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = 'posh-vcpkg.psm1'

# Version number of this module.
ModuleVersion = '0.0.1'

# ID used to uniquely identify this module
GUID = '948f02ab-fc99-4a53-8335-b6556eef129b'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

FunctionsToExport = @('TabExpansion')
CmdletsToExport = @()
VariablesToExport = @()
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess.
# This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = 
@{
    PSData =
    @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('vcpkg', 'tab', 'tab-completion', 'tab-expansion', 'tabexpansion')
    }
}

}
