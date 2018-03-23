[CmdletBinding()]
param()

scp -B ras0219@Roberts-Mini:/var/vsts/_work/2/s/buildlinux/*_x64-osx.xml \\vcpkg-000\General\Results\
scp -B vcpkg@13.91.246.184:/var/vsts/_work/1/s/buildlinux/*_x64-linux.xml \\vcpkg-000\General\Results\
