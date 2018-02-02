$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

CreateTripletsForVS -vsInstallPath $VISUAL_STUDIO_2017_STABLE_PATH -vsInstallNickname $VISUAL_STUDIO_2017_STABLE_NICKNAME -outputDir .\triplets