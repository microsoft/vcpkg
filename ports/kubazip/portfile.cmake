vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/zip
    REF bc02f019b4c8c46a0a744ad678228e4b59d579b4
    SHA512 3947402b5b2ebbdb526b0833c23e695f6f570e2ebaa92e6eaae7567533e09a0447eae463aac4f296ba7ecae01110a816d38e39416c81218cb942b55eb0e37ec3
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
