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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/2.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vinniefalco/LuaBridge/archive/2.1.zip"
    FILENAME "luabridge-2.1.zip"
    SHA512 7f07e99cb5b4ed4460756fad8864e4a6af51e819be6e11d27fd37e97554c004ea46f18dfabf4abdc6cfb0ad63ac7402bd940048dca719ad328d89917e827c2da
)
vcpkg_extract_source_archive(${ARCHIVE})

file(
    COPY ${CURRENT_BUILDTREES_DIR}/src/LuaBridge-2.1/Source/LuaBridge
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${CURRENT_PORT_DIR}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/luabridge RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME luabridge)
