include(vcpkg_common_functions)

set(FREERDP_VERSION 2.0.0-beta1+android11)
set(FREERDP_HASH c6682f0e555cac51c1d5ddaa910e507043e067af2bb19db626389ae648cbbfe1ab156e14caf3803f98fc1d574a0491629a76282080b3d9c9d382f2f662d2e06c)

string(REGEX REPLACE "\\+" "-" FREERDP_VERSION_ESCAPED ${FREERDP_VERSION})
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/FreeRDP-${FREERDP_VERSION_ESCAPED})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/FreeRDP/FreeRDP/archive/${FREERDP_VERSION}.tar.gz"
    FILENAME "${FREERDP_VERSION}.tar.gz"
    SHA512 ${FREERDP_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(FREERDP_CRT_LINKAGE -DMSVC_RUNTIME=static)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -WITH_DEBUG_SYMBOLS=ON ${FREERDP_CRT_LINKAGE})

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freerdp-client2.dll" "${CURRENT_PACKAGES_DIR}/bin/freerdp-client2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freerdp2.dll"        "${CURRENT_PACKAGES_DIR}/bin/freerdp2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/winpr-tools2.dll"    "${CURRENT_PACKAGES_DIR}/bin/winpr-tools2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/winpr2.dll"          "${CURRENT_PACKAGES_DIR}/bin/winpr2.dll")

   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freerdp-client2.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/freerdp-client2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freerdp2.dll"        "${CURRENT_PACKAGES_DIR}/debug/bin/freerdp2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/winpr-tools2.dll"    "${CURRENT_PACKAGES_DIR}/debug/bin/winpr-tools2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/winpr2.dll"          "${CURRENT_PACKAGES_DIR}/debug/bin/winpr2.dll")
endif()

if(NOT TARGET_TRIPLET MATCHES "uwp")   
    make_directory("${CURRENT_PACKAGES_DIR}/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/winpr-hash.exe"     "${CURRENT_PACKAGES_DIR}/tools/winpr-hash.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/winpr-makecert.exe" "${CURRENT_PACKAGES_DIR}/tools/winpr-makecert.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/wfreerdp.exe"       "${CURRENT_PACKAGES_DIR}/tools/wfreerdp.exe")

    make_directory("${CURRENT_PACKAGES_DIR}/debug/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/winpr-hash.exe"     "${CURRENT_PACKAGES_DIR}/debug/tools/winpr-hash.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/winpr-makecert.exe" "${CURRENT_PACKAGES_DIR}/debug/tools/winpr-makecert.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/wfreerdp.exe"       "${CURRENT_PACKAGES_DIR}/debug/tools/wfreerdp.exe")
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/freerdp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freerdp/LICENSE ${CURRENT_PACKAGES_DIR}/share/freerdp/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/freerdp/cmake)