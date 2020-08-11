vcpkg_fail_port_install(ON_TARGET "LINUX" "OSX" "UWP" "ANDROID" ON_ARCH "arm")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.microsoft.com/download/a/e/7/ae743f1f-632b-4809-87a9-aa1bb3458e31/DXSDK_Jun10.exe"
    FILENAME "DXSDK_Jun10.exe"
    SHA512 4869ac947a35cd0d6949fbda17547256ea806fef36f48474dda63651f751583e9902641087250b6e8ccabaab85e51effccd9235dc6cdf64e21ec2b298227fe19
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)


set(LIB_DIR "${SOURCE_PATH}/Lib/${VCPKG_TARGET_ARCHITECTURE}")
set(DEBUG_LIBS
    ${LIB_DIR}/D3DCSXd.lib
    ${LIB_DIR}/d3dx10d.lib
    ${LIB_DIR}/d3dx11d.lib
    ${LIB_DIR}/d3dx9d.lib
    ${LIB_DIR}/xapobased.lib
)
set(RELEASE_LIBS
    ${LIB_DIR}/D3DCSX.lib
    ${LIB_DIR}/d3dx10.lib
    ${LIB_DIR}/d3dx11.lib
    ${LIB_DIR}/d3dx9.lib
    ${LIB_DIR}/xapobase.lib
)
# Libs without a debug part
set(OTHER_LIBS
    ${LIB_DIR}/d2d1.lib
    ${LIB_DIR}/d3d10.lib
    ${LIB_DIR}/d3d10_1.lib
    ${LIB_DIR}/d3d11.lib
    ${LIB_DIR}/d3d9.lib
    ${LIB_DIR}//d3dcompiler.lib
    ${LIB_DIR}/d3dxof.lib
    ${LIB_DIR}/dinput8.lib
    ${LIB_DIR}/dsound.lib
    ${LIB_DIR}/dwrite.lib
    ${LIB_DIR}/DxErr.lib
    ${LIB_DIR}/dxgi.lib
    ${LIB_DIR}/dxguid.lib
    ${LIB_DIR}/X3DAudio.lib
    ${LIB_DIR}/XAPOFX.lib
    ${LIB_DIR}/XInput.lib
)
if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL "x86")
    list(APPEND OTHER_LIBS ${LIB_DIR}/dsetup.lib)
endif()

#install(DIRECTORY "${SOURCE_PATH}/Include" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY "${SOURCE_PATH}/Include/" DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${RELEASE_LIBS} ${OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${DEBUG_LIBS} ${OTHER_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)


# # Handle copyright
file(INSTALL "${SOURCE_PATH}/Documentation/License Agreements/DirectX SDK EULA.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
