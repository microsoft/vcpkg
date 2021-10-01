vcpkg_fail_port_install(ON_TARGET "LINUX" "OSX" "UWP" "ANDROID" ON_ARCH "arm")

if(EXISTS "${CURRENT_INSTALLED_DIR}/share/dxsdk-d3dx/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if dxsdk-d3dx is installed. Please remove dxsdk-d3dx, and try to install ${PORT} again if you need it.")
endif()

message(WARNING "Build ${PORT} is deprecated, untested in CI, and requires the use of the DirectSetup legacy REDIST solution. See https://aka.ms/dxsdk for more information.")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.microsoft.com/download/A/E/7/AE743F1F-632B-4809-87A9-AA1BB3458E31/DXSDK_Jun10.exe"
    FILENAME "DXSDK_Jun10_SHA256.exe"
    SHA512 24e1e9bda319b780124b865f4640822cfc44e4d18fbdcc8456d48fe54081652ce4ddb63d3bd8596351057cbae50fc824b8297e99f0f7c97547153162562ba73f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# See https://walbourn.github.io/the-zombie-directx-sdk/
set(INC_DIR "${SOURCE_PATH}/Include")
set(LIB_DIR "${SOURCE_PATH}/Lib/${VCPKG_TARGET_ARCHITECTURE}")

set(HEADERS
    ${INC_DIR}/audiodefs.h
    ${INC_DIR}/comdecl.h
    ${INC_DIR}/D3DX10.h
    ${INC_DIR}/d3dx10async.h
    ${INC_DIR}/D3DX10core.h
    ${INC_DIR}/D3DX10math.h
    ${INC_DIR}/D3DX10math.inl
    ${INC_DIR}/D3DX10mesh.h
    ${INC_DIR}/D3DX10tex.h
    ${INC_DIR}/D3DX11.h
    ${INC_DIR}/D3DX11async.h
    ${INC_DIR}/D3DX11core.h
    ${INC_DIR}/D3DX11tex.h
    ${INC_DIR}/d3dx9.h
    ${INC_DIR}/d3dx9anim.h
    ${INC_DIR}/d3dx9core.h
    ${INC_DIR}/d3dx9effect.h
    ${INC_DIR}/d3dx9math.h
    ${INC_DIR}/d3dx9math.inl
    ${INC_DIR}/d3dx9mesh.h
    ${INC_DIR}/d3dx9shader.h
    ${INC_DIR}/d3dx9shape.h
    ${INC_DIR}/d3dx9tex.h
    ${INC_DIR}/d3dx9xof.h
    ${INC_DIR}/D3DX_DXGIFormatConvert.inl
    ${INC_DIR}/dsetup.h
    ${INC_DIR}/dxdiag.h
    ${INC_DIR}/DxErr.h
    ${INC_DIR}/dxfile.h
    ${INC_DIR}/dxsdkver.h
    ${INC_DIR}/PIXPlugin.h
    ${INC_DIR}/rmxfguid.h
    ${INC_DIR}/rmxftmpl.h
    ${INC_DIR}/xact3.h
    ${INC_DIR}/xact3d3.h
    ${INC_DIR}/xact3wb.h
    ${INC_DIR}/XDSP.h
    ${INC_DIR}/xma2defs.h)

set(DEBUG_LIBS
    ${LIB_DIR}/d3dx10d.lib
    ${LIB_DIR}/d3dx11d.lib
    ${LIB_DIR}/d3dx9d.lib
)
set(RELEASE_LIBS
    ${LIB_DIR}/d3dx10.lib
    ${LIB_DIR}/d3dx11.lib
    ${LIB_DIR}/d3dx9.lib
)
set(OTHER_LIBS
    ${LIB_DIR}/d3dxof.lib
    ${LIB_DIR}/DxErr.lib
)
if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL "x86")
    list(APPEND OTHER_LIBS ${LIB_DIR}/dsetup.lib)
endif()

set(XINPUT13_HEADER ${INC_DIR}/XInput.h)
set(XINPUT13_LIB ${LIB_DIR}/XInput.lib)

set(XAUDIO27_HEADERS
    ${INC_DIR}/X3DAudio.h
    ${INC_DIR}/XAPO.h
    ${INC_DIR}/XAPOBase.h
    ${INC_DIR}/XAPOFX.h
    ${INC_DIR}/XAudio2.h
    ${INC_DIR}/XAudio2fx.h)
set(XAUDIO27_DEBUG_LIBS ${LIB_DIR}/xapobased.lib)
set(XAUDIO27_RELEASE_LIBS ${LIB_DIR}/xapobase.lib)
set(XAUDIO27_OTHER_LIBS
    ${LIB_DIR}/X3DAudio.lib
    ${LIB_DIR}/XAPOFX.lib
)

set(XP_HEADERS
    ${INC_DIR}/D3D10.h
    ${INC_DIR}/D3D10effect.h
    ${INC_DIR}/d3d10misc.h
    ${INC_DIR}/d3d10sdklayers.h
    ${INC_DIR}/D3D10shader.h
    ${INC_DIR}/D3D10_1.h
    ${INC_DIR}/D3D10_1shader.h
    ${INC_DIR}/D3D11.h
    ${INC_DIR}/D3D11SDKLayers.h
    ${INC_DIR}/D3D11Shader.h
    ${INC_DIR}/D3Dcommon.h
    ${INC_DIR}/D3Dcompiler.h
    ${INC_DIR}/D3DCSX.h
    ${INC_DIR}/D3DX_DXGIFormatConvert.inl
    ${INC_DIR}/xnamath.h
    ${INC_DIR}/xnamathconvert.inl
    ${INC_DIR}/xnamathmatrix.inl
    ${INC_DIR}/xnamathmisc.inl
    ${INC_DIR}/xnamathvector.inl)

set(XP_DEBUG_LIBS ${LIB_DIR}/D3DCSXd.lib)
set(XP_RELEASE_LIBS ${LIB_DIR}/D3DCSX.lib)
set(XP_OTHER_LIBS
    ${LIB_DIR}/d3dcompiler.lib
    ${LIB_DIR}/dxguid.lib
)


#install(DIRECTORY "${SOURCE_PATH}/Include" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${RELEASE_LIBS} ${OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${DEBUG_LIBS} ${OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

if(("xinput1-3" IN_LIST FEATURES) OR ("xp" IN_LIST FEATURES))
   file(COPY ${XINPUT13_HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
   file(COPY ${XINPUT13_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
   file(COPY ${XINPUT13_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

if(("xaudio2-7" IN_LIST FEATURES) OR ("xp" IN_LIST FEATURES))
   file(COPY ${XAUDIO27_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
   file(COPY ${XAUDIO27_RELEASE_LIBS} ${XAUDIO27_OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
   file(COPY ${XAUDIO27_DEBUG_LIBS} ${XAUDIO27_OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

if("xp" IN_LIST FEATURES)
    file(COPY ${XP_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
    file(COPY ${XP_RELEASE_LIBS} ${XP_OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${XP_DEBUG_LIBS} ${XP_OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/Documentation/License Agreements/DirectX SDK EULA.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
