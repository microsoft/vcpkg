# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/liblo-0.29)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/radarsat1/liblo/archive/0.29.zip"
    FILENAME "liblo.0.29.zip"
    SHA512 a2b7c67f7e7a3739f4481a4c199f7cb1b026cfefaa1a6e63acefeb801a5404e3bd622cccc33da225550f8c4fd61c3d3b975a3c61763c0d189fceb4cf5f622206
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DTHREADING=1
)

vcpkg_install_cmake()

# Install needed files into package directory
file(INSTALL ${CURRENT_PACKAGES_DIR}/lib/cmake/liblo/libloConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblo)
file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/oscsend.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblo)
file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/oscdump.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblo)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/liblo)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/oscsend.exe ${CURRENT_PACKAGES_DIR}/bin/oscdump.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/oscsend.exe ${CURRENT_PACKAGES_DIR}/debug/bin/oscdump.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblo RENAME copyright)
