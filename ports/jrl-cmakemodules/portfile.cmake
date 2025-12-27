vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jrl-umi3218/jrl-cmakemodules
    REF v${VERSION}
    SHA512 32198c5778586b0be83398fd5e99901d08be266cec441e1f7e75700e6a3d8734db4888b7a1e779005095e3a842d6cafcebba6a8bf1c6f10fd3ac5ed366fd0011
    PATCHES
        sdformat_auto_version.diff
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DOCUMENTATION=OFF
        -DBUILDING_ROS2_PACKAGE=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/_unittests")
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL
        "${CMAKE_CURRENT_LIST_DIR}/usage"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
