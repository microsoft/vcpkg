vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/nameof
    REF "v${VERSION}"
    SHA512 88eff4fb9a137c388b39d67eb9e213ed93e6a553dd1295d5db04c6fbc254f6df3da8800de2e0675f574bb3f83ae05141f71efe30ccdd4601a42cf19adaea6e79
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNAMEOF_OPT_BUILD_EXAMPLES=OFF
        -DNAMEOF_OPT_BUILD_TESTS=OFF
        -DNAMEOF_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
