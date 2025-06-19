vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/zip
    REF 0bb9deec79589aea4e1923dfc2c4fc5b8dfe1770
    SHA512 f98edabddec0677d5d80129640077b45ac566fa8b5bb325d1906326c01a6f6a486a25ed0b5e2a29366bf0130074e3c9ebb9dcfd7f3ab9084bcd2daa3f0267145
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_DISABLE_TESTING=ON"
        "-DNEW_PROJECT_NAME=kubazip"
        "-DNEW_INSTALL_PATH=include/${PORT}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
