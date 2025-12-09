vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO free-audio/clap
    REF "${VERSION}"
    SHA512 4a532acf85b89f7da733bff88bdef58a273dc19c14b4bb9bf747717d8c2450351e506fefab388cd8a644d01237b1d39ef5adb355957b30d7851aeb6a2f648492
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/clap"
)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
