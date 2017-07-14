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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/allegro5-5.2.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/liballeg/allegro5/archive/5.2.1.0.zip"
    FILENAME "allegro5-5.2.1.0.zip"
    SHA512 3271483714699e10d6ec0c0d94491d20d227b5a767d5134b592418bd0838c64d3a6448ba8448d568aeb846a6b50004656507deabb2d82dfe748f4ccc83ba1a53
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DSHARED=OFF -DWANT_DOCS=OFF -DALLEGRO_SDL=OFF -DWANT_STATIC_RUNTIME=ON -DWANT_DEMO=OFF -DWANT_EXAMPLES=OFF -DWANT_CURL_EXAMPLE=OFF -DWANT_TESTS=OFF
    OPTIONS_RELEASE -DWANT_ALLOW_SSE=ON
    OPTIONS_DEBUG -DWANT_ALLOW_SSE=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/allegro5)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/allegro5/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/allegro5/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)