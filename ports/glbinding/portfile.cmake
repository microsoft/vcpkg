# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glbinding-2.1.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cginternals/glbinding/archive/v2.1.1.zip"
    FILENAME "glbinding-2.1.1.zip"
    SHA512 66b21853a4f4760b7b22cafd5211958769c513e83be999018fe79cf56a9271e0e28566caaa2286393f54ac2154d564a68d12159598d03c965adf6756f3753f11
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH})
#vcpkg_build_cmake()
vcpkg_install_cmake()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/glbinding ${CURRENT_PACKAGES_DIR}/share/glbinding)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/glbinding/glbinding-export-debug.cmake GLBINDING_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" GLBINDING_DEBUG_MODULE "${GLBINDING_DEBUG_MODULE}")
string(REPLACE "glbindingd.dll" "bin/glbindingd.dll" GLBINDING_DEBUG_MODULE "${GLBINDING_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export-debug.cmake "${GLBINDING_DEBUG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export-release.cmake RELEASE_CONF)
string(REPLACE "glbinding.dll" "bin/glbinding.dll" RELEASE_CONF "${RELEASE_CONF}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export-release.cmake "${RELEASE_CONF}")
file(REMOVE ${CURRENT_PACKAGES_DIR}/glbinding-config.cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/glbinding-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export.cmake ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-config.cmake)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/glbinding.dll ${CURRENT_PACKAGES_DIR}/bin/glbinding.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/glbindingd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/glbindingd.dll)
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
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/glbinding)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glbinding/LICENSE ${CURRENT_PACKAGES_DIR}/share/glbinding/copyright)

vcpkg_copy_pdbs()