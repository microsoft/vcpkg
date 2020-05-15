#[[

Building steps for ogre-next[d3d9]:

1. Download and install "Microsoft DirectX SDK"
https://www.microsoft.com/en-us/download/confirmation.aspx?id=6812

2. Set env variable
set DXSDK_DIR=C:/Program Files (x86)/Microsoft DirectX SDK (June 2010)

3. Install port
.\vcpkg.exe install ogre-next[d3d9] --triplet x64-windows

]]

set(VCPKG_ENV_PASSTHROUGH DXSDK_DIR)
