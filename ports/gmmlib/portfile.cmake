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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gmmlib-intel-gmmlib-18.3.pre2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/intel/gmmlib/archive/intel-gmmlib-18.3.pre2.zip"
    FILENAME "intel-gmmlib-18.3.pre2.zip"
    SHA512 6c47b72c23b50694352d499dee884342054763c3004ded4d946f0dcf8d09dd53ec88a312e5694c77a1753317b13e52785f18d1c93602b7964d4dd1bc4b640d16
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_BUILD_TYPE=Release -DARCH=64
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/intel/gmmlib/intel-gmmlib-18.3.pre2/LICENSE.md"
    FILENAME "LICENSE.md"
    SHA512 7ccef6f0c48434aae9bed1169b8eef65890b0d782cd489997699f1c116e7a6658aa3cde4bb7efc7c67e28740b269b620e76b6459957f3ff7b756187a0269827e
)

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/gmmlib-intel-gmmlib-18.3.pre2/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/gmmlib RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Scripts)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Resource)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/GlobalInfo)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME gmmlib)


