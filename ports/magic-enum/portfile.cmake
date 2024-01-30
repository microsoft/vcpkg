vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/magic_enum
    REF "v${VERSION}"
    SHA512 f1b412d15e0ef624b4588adba00a18ed12eeb1f0dabc021d53a7c047b8976ecb07701b76040f47c77c75e00151619dbce1f9a75f471db04340156a39044768f3
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
        -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
        -DMAGIC_ENUM_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/magic_enum PACKAGE_NAME magic_enum)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
