# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/globjects-1.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cginternals/globjects/archive/v1.0.0.zip"
    FILENAME "globjects-1.0.0.zip"
    SHA512 e03ae16786b11891a61f0e2f85b0d98a858d1bad3cf4c45944982d6a753dbaa8b28975dc02153360a5ac0f3be73fe86c91af130cfc0dda7459dd782f16868eeb
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPTION_BUILD_TESTS=OFF
        -DOPTION_BUILD_GPU_TESTS=OFF
)
#vcpkg_build_cmake()
vcpkg_install_cmake()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/globjects ${CURRENT_PACKAGES_DIR}/share/globjects)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/globjects/globjects-export-debug.cmake globjects_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" globjects_DEBUG_MODULE "${globjects_DEBUG_MODULE}")
string(REPLACE "globjectsd.dll" "bin/globjectsd.dll" globjects_DEBUG_MODULE "${globjects_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/globjects/globjects-export-debug.cmake "${globjects_DEBUG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/globjects/globjects-export-release.cmake RELEASE_CONF)
string(REPLACE "globjects.dll" "bin/globjects.dll" RELEASE_CONF "${RELEASE_CONF}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/globjects/globjects-export-release.cmake "${RELEASE_CONF}")
file(REMOVE ${CURRENT_PACKAGES_DIR}/globjects-config.cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/globjects-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/globjects/globjects-export.cmake ${CURRENT_PACKAGES_DIR}/share/globjects/globjects-config.cmake)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/globjects.dll ${CURRENT_PACKAGES_DIR}/bin/globjects.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/globjectsd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/globjectsd.dll)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/data ${CURRENT_PACKAGES_DIR}/share/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/data)
file(REMOVE ${CURRENT_PACKAGES_DIR}/AUTHORS
            ${CURRENT_PACKAGES_DIR}/LICENSE
            ${CURRENT_PACKAGES_DIR}/README.md
            ${CURRENT_PACKAGES_DIR}/VERSION
            ${CURRENT_PACKAGES_DIR}/debug/AUTHORS
            ${CURRENT_PACKAGES_DIR}/debug/LICENSE
            ${CURRENT_PACKAGES_DIR}/debug/README.md
            ${CURRENT_PACKAGES_DIR}/debug/VERSION
    )

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/globjects)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/globjects/LICENSE ${CURRENT_PACKAGES_DIR}/share/globjects/copyright)

vcpkg_copy_pdbs()
