[CmdletBinding()]
param()

scp -B ras0219@Roberts-Mini:/var/vsts/_work/2/s/*_x64-osx.xml \\vcpkg-000.redmond.corp.microsoft.com\General\Results\
if (!$?) { throw "failed" }
scp -B vcpkg@13.91.246.184:/var/vsts/_work/1/s/*_x64-linux.xml \\vcpkg-000.redmond.corp.microsoft.com\General\Results\
if (!$?) { throw "failed" }
ssh ras0219@Roberts-Mini rm /var/vsts/_work/2/s/*_x64-osx.xml
if (!$?) { throw "failed" }
ssh vcpkg@13.91.246.184 rm /var/vsts/_work/1/s/*_x64-linux.xml
if (!$?) { throw "failed" }
