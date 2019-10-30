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

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VERSION 3.0)

vcpkg_download_distfile(ARCHIVE
    URLS "http://wordnetcode.princeton.edu/${VERSION}/WordNet-${VERSION}.tar.gz"
    FILENAME "wordnet-${VERSION}.tar.gz"
    SHA512 9539bc016d710f31d65072bbf5068edffcd735978d8cc6f1b361b19428b97546ef6c7e246e1b6f2ff4557a0885a8305341e35173a6723f0740dda18d097ca248
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    REF ${VERSION}
    # (Optional) Read the docs for how to generate patches at: 
    # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    PATCHES
        extern_c_global_vars.patch
    #   002_more_port_fixes.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/wordnet-config.cmake.in DESTINATION ${SOURCE_PATH})

if("dbfiles" IN_LIST FEATURES)
    vcpkg_download_distfile(WORDNET_DICT_DBFILES
        URLS "http://wordnetcode.princeton.edu/wn3.1.dict.tar.gz"
        FILENAME "wordnet-cache/wn3.1.dict.tar.gz"
        SHA512 16dca17a87026d8a0b7b4758219cd21a869c3ef3da23ce7875924546f2eacac4c2f376cb271b798b2c458fe8c078fb43d681356e3d9beef40f4bd88d3579394f
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/dict/")
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH WORDNET_DICT_DBFILES_EX
        ARCHIVE ${WORDNET_DICT_DBFILES}
        REF 3.1
        WORKING_DIRECTORY ${SOURCE_PATH}
    )
    file(RENAME ${WORDNET_DICT_DBFILES_EX} "${SOURCE_PATH}/dict")
endif()

set (WORDNET_DICT_PATH "${CURRENT_PACKAGES_DIR}/tools/${PORT}/dict")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DWORDNET_DICT_PATH=${WORDNET_DICT_PATH}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wordnet RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME wordnet)
