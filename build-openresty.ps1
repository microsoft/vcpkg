# Run after build-vcpkg
# After running this script right click all the files in the vcpkg dir
# use 7-zip to add to vcpkg.zip
# rename to vcpkg-<ver>.zip
# upload to Amazon S3 intelight/vcpkg
$ErrorActionPreference = "Stop"

$vcpkg = "$pwd\installed\x64-windows-mixed"
$lualocal = "$pwd\buildtrees\openresty\lualocal"
$patches = "$pwd\openresty\patches"
$openresty = "$pwd\vcpkg\installed\openresty"
$redis = "$pwd\vcpkg\installed\redis"

& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -SkipAutomaticLocation -Arch amd64
$env:Path = "$vcpkg\tools\openssl;$env:Path"

# Prepare directories
if(Test-Path buildtrees\openresty) {
  Remove-Item buildtrees\openresty -recurse -force
}
New-Item buildtrees\openresty\luarocks -type directory -force 2>&1 | out-null

if(Test-Path "$openresty") {
  Remove-Item "$openresty" -recurse -force
}
New-Item "$openresty" -type directory -force 2>&1 | out-null

if(Test-Path "$redis") {
  Remove-Item "$redis" -recurse -force
}
New-Item "$redis" -type directory -force 2>&1 | out-null

# Build luarocks
tar xf .\openresty\zips\luarocks-3.9.2-win32.zip --strip-components=1 -C .\buildtrees\openresty\luarocks\
cd buildtrees\openresty\luarocks
.\install.bat /SELFCONTAINED /NOREG /NOADMIN /MSVC /Q /F `
  /P "$lualocal" `
  /INC "$vcpkg\include\luajit" `
  /LIB "$vcpkg\lib" `
  /BIN "$vcpkg\tools"
cd ..\..\..

# Build lua modules
cd buildtrees\openresty\lualocal
.\luarocks.bat install lua-cjson 2.1.0.6-1
.\luarocks.bat install lbase64 20120820-1
.\luarocks.bat install inspect 3.1.1-0
.\luarocks.bat install valua 0.3-1
.\luarocks.bat install router 2.1-0
.\luarocks.bat install lua-path 0.3.1-1
# moses must be pinned at 1.6.1-1, recent versions switch the order of arguments and completely break maxprofile
.\luarocks.bat install moses 1.6.1-1
.\luarocks.bat install uuid 0.2-1
.\luarocks.bat install lua-resty-openssl 0.8.26-1
.\luarocks.bat install lua-resty-jwt 0.2.3-0
.\luarocks.bat install lua-resty-http 0.15-0
.\luarocks.bat install lua-resty-session 3.10-1
.\luarocks.bat install lua-resty-openidc 1.7.6-3
.\luarocks.bat install luafilesystem 1.8.0-1
.\luarocks.bat install lsqlite3 0.9.5-1 "SQLITE_INCDIR=$vcpkg\include" "SQLITE_LIBDIR=$vcpkg\lib"
.\luarocks.bat install luasql-sqlite3 2.5.0-1 "SQLITE_INCDIR=$vcpkg\include" "SQLITE_LIBDIR=$vcpkg\lib"

.\luarocks.bat unpack luaossl 20190731-0
cd luaossl-20190731-0\luaossl-rel-20190731
cp "$patches\luaossl\*" .\
git init .
git apply --verbose 0001-fix-link-with-vcpkg-static-openssl.patch
..\..\luarocks.bat make "CRYPTO_DIR=$vcpkg" "OPENSSL_DIR=$vcpkg"
cd ..\..

.\luarocks.bat unpack phpass 1.0-1
cd phpass-1.0-1
cp "$patches\phpass\*" .\
git init .
git apply --verbose 0001-replace-luacrypto-with-luaossl.patch
cd lua-phpass
..\..\luarocks.bat make
cd ..\..

.\luarocks.bat unpack luajwt 1.3-4
cd luajwt-1.3-4
cp "$patches\luajwt\*" .\
git init .
git apply --verbose 0001-replace-luacrypto-with-luaossl.patch
cd luajwt
..\..\luarocks.bat make
cd ..\..
cd ..\..\..

# Copy openresty and lua into installed dir
tar xf .\openresty\zips\openresty-1.25.3.1-win64.zip --strip-components=1 -C "$openresty"
cp -r "$lualocal\systree\lib\lua\5.1\*" "$openresty\"
cp -r "$lualocal\systree\share\lua\5.1\*" "$openresty\lua\"
Set-Content  "$openresty/logs/empty" -value '🤦'

# Copy redis installed dir
tar xf .\openresty\zips\Redis-x64-3.2.100.zip -C "$redis"
