# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libnonius/nonius
    REF 6396b7ad6685843eea63754ffa567dd66353c1a8
    SHA512 3b824a6011f1dbe116271dd76e8214ed98d73dfc215d7c9242bf298eb0e7ee3a3e3198f477b49fdbe098ac6e3e4edd8ca7bd2e03cc2036189bf3630ef3fcdca2
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
