include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/fruit
    REF v3.4.0
    SHA512 d78c76432c77acc4cc6ccf3fd9627a3fb2a0aa55d1baf7346422e9f1c1e048237d136588b44cfa943b542b43adbbb62fcd524e4a1cb870e9ffe8b7cf4dadb35d
    HEAD_REF master
)

# TODO: Make boost an optional dependency?
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFRUIT_USES_BOOST=False
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/fruit/copyright COPYONLY)
