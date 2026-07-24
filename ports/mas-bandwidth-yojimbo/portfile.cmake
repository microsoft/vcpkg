vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/yojimbo
    REF "v${VERSION}"
    SHA512 437fcd8b4fcd8369eb1a3e153361720bab2cdd99882d6400a7066d6f32185d2d9f480e37c370a749be4fac37c6b357af79b18815919860d2987112857d302165
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
