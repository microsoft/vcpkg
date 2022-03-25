
$rootPath=$args[0]

$cppSrcPath = "$rootPath/cpp/src"
if($cppSrcPath)
{
Write-Output "Processing $cppSrcPath"
$projectFiles = Get-ChildItem -Path $cppSrcPath -Filter *.vcxproj -Recurse -ErrorAction SilentlyContinue -Force

  foreach($proj in $projectFiles)
  {
      Write-Output $proj.FullName
      $content = Get-Content -Path $proj.FullName
      $content = $content -replace '<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">', '<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild" Condition="''$(UseVcpkg)'' != ''yes''">'
      $content = $content -replace '<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>',''
      $content = $content -replace '<RuntimeLibrary>MultiThreaded</RuntimeLibrary>',''
      $content | Set-Content -Path $proj.FullName
  }
}
else
{
  Write-Error "Error: No path defined!"
}

# Download nuget file with .zip extention to temporary folder
$tmpPath = [System.IO.Path]::GetTempPath()
$msbuilderDlPath = "$tmpPath/zeroc.icebuilder.msbuild.5.0.7.zip"
Invoke-WebRequest -Uri "https://globalcdn.nuget.org/packages/zeroc.icebuilder.msbuild.5.0.7.nupkg" -OutFile $msbuilderDlPath

# Ensure destination folder exists.
$msBuilderPath = "$rootPath/cpp/msbuild/packages/zeroc.icebuilder.msbuild.5.0.7"
if(-Not (Test-Path -Path $msBuilderPath))
{
  New-Item -Path $msBuilderPath -ItemType Directory -Force
}

# Extract nuget archive to $msBuilderPath and remove the downloaded file
Expand-Archive -Path $msbuilderDlPath -DestinationPath $msBuilderPath
Remove-Item -Path $msbuilderDlPath


