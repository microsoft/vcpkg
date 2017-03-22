include(vcpkg_common_functions)
set(VERSION 0.14.0alpha4)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/uwebsockets-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uWebSockets/uWebSockets/archive/v${VERSION}.zip"
    FILENAME "uwebsockets-v${VERSION}.zip"
    SHA512 19eeb87e53b8bd31bf3354da170366a9398845aadef1f4859793767b5f74f9ae52efd1dcfa24375e600f19cf9e3d165dcc1e6c50f4df1a526ccf63fa5a5429cb
)
vcpkg_extract_source_archive(${ARCHIVE})

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
    set(BUILD_OUTPUT ${SOURCE_PATH})
else ()
    set(MSBUILD_PLATFORM "x64")
    set(BUILD_OUTPUT ${SOURCE_PATH}/x64)
endif ()

vcpkg_execute_required_process(
    COMMAND msbuild /p:Configuration=Release /p:Platform=${MSBUILD_PLATFORM} VC++.vcxproj
    WORKING_DIRECTORY ${SOURCE_PATH}
)

file(COPY ${BUILD_OUTPUT}/Release/uWS.dll ${BUILD_OUTPUT}/Release/uWS.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${BUILD_OUTPUT}/Release/uWS.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_execute_required_process(
    COMMAND msbuild /p:Configuration=Debug /p:Platform=${MSBUILD_PLATFORM} VC++.vcxproj
    WORKING_DIRECTORY ${SOURCE_PATH}
)

file(COPY ${BUILD_OUTPUT}/Debug/uWS.dll ${BUILD_OUTPUT}/Debug/uWS.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${BUILD_OUTPUT}/Debug/uWS.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(GLOB HEADERS ${SOURCE_PATH}/src/*.h)
file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/uWS)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/uwebsockets/copyright)
