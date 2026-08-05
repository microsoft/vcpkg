vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/yojimbo
    REF "v${VERSION}"
    SHA512 fab536892713263f00a070aeb052826c88302cd4709c215657fda59c1dd6e46d709359d61f9a1db4bceaa22459b4eda3a826fbfcd77c862b763ec59249b007dc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYOJIMBO_SYSTEM_DEPS=ON
        -DYOJIMBO_BUILD_TESTS=OFF
        -DYOJIMBO_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENCE"
    "${SOURCE_PATH}/tlsf/tlsf.h"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
