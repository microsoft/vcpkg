vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO free-audio/clap
    REF 1.1.10
    SHA512 50d2b8e35ebcb3dfd4e057ddcf22e92204ca90a700527fe802c7f3ae678e77c970f789f2fbbedd58964a1d1ec72376e7c8d488c10fe03d39fbd1cd5d6a8630a1
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
