vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/krpc/krpc/releases/download/v${VERSION}/krpc-cnano-${VERSION}.zip"
    FILENAME "krpc-cnano-${VERSION}.zip"
    SHA512 acd10d610b09fdfb788710e8d0cf13078de16439b90538833cd4e41a29aa51fdb75767ae6ca70148a42843d7f99ac1183894af54fb07a9682762597217a4ae4b
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "krpc-cnano-${VERSION}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKRPC_FETCH_NANOPB=OFF
        -DKRPC_REGENERATE_PROTO=OFF
        -DKRPC_COMMUNICATION_TCP=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/krpc_cnano PACKAGE_NAME krpc_cnano)
vcpkg_copy_pdbs()

# The installed headers must select the same fixed transport as the library, without CMake usage requirements.
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/krpc_cnano/communication.h"
    "#pragma once"
    "#pragma once\n\n#ifndef KRPC_COMMUNICATION_TCP\n#define KRPC_COMMUNICATION_TCP\n#endif"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LESSER"
    "${CURRENT_INSTALLED_DIR}/share/nanopb/copyright"
)
