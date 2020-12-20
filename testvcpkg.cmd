vcpkg install directxmath
@if errorlevel 1 goto :eof

vcpkg install directxtk
@if errorlevel 1 goto :eof
vcpkg install directxtk:x64-windows
@if errorlevel 1 goto :eof
vcpkg install directxtk:arm64-windows
@if errorlevel 1 goto :eof
vcpkg install directxtk:x86-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtk:x64-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtk:arm-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtk:arm64-uwp
@if errorlevel 1 goto :eof

vcpkg install directxtk12
@if errorlevel 1 goto :eof
vcpkg install directxtk12:x64-windows
@if errorlevel 1 goto :eof
vcpkg install directxtk12:arm64-windows
@if errorlevel 1 goto :eof
vcpkg install directxtk12:x86-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtk12:x64-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtk12:arm-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtk12:arm64-uwp
@if errorlevel 1 goto :eof

vcpkg install directxtex[openexr] --recurse
@if errorlevel 1 goto :eof
vcpkg install directxtex:x64-windows
@if errorlevel 1 goto :eof
vcpkg install directxtex:arm64-windows
@if errorlevel 1 goto :eof
vcpkg install directxtex:x86-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtex:x64-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtex:arm-uwp
@if errorlevel 1 goto :eof
vcpkg install directxtex:arm64-uwp
@if errorlevel 1 goto :eof

vcpkg install directxmesh
@if errorlevel 1 goto :eof
vcpkg install directxmesh:x64-windows
@if errorlevel 1 goto :eof
vcpkg install directxmesh:arm64-windows
@if errorlevel 1 goto :eof
vcpkg install directxmesh:x86-uwp
@if errorlevel 1 goto :eof
vcpkg install directxmesh:x64-uwp
@if errorlevel 1 goto :eof
vcpkg install directxmesh:arm-uwp
@if errorlevel 1 goto :eof
vcpkg install directxmesh:arm64-uwp
@if errorlevel 1 goto :eof

vcpkg install uvatlas
@if errorlevel 1 goto :eof
vcpkg install uvatlas:x64-windows
@if errorlevel 1 goto :eof
vcpkg install uvatlas:arm64-windows
@if errorlevel 1 goto :eof
vcpkg install uvatlas:x86-uwp
@if errorlevel 1 goto :eof
vcpkg install uvatlas:x64-uwp
@if errorlevel 1 goto :eof
vcpkg install uvatlas:arm-uwp
@if errorlevel 1 goto :eof
vcpkg install uvatlas:arm64-uwp
