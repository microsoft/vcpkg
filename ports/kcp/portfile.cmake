vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skywind3000/kcp
    REF 8004f7eba5d1bf33f0691eef5f887f2cd3140cb5
    SHA512 5170c1febc09482e1d032cf5aac5bd5cce706e19b58c6a7eddd1c0082895d8b932f5bdf04d47af1994408c4e8cfc37652e11c7d3f7e5addac88afc42764b06cf
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
