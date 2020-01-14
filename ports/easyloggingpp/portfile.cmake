include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO muflihun/easyloggingpp
    REF v9.96.7
    SHA512 53ee637cd7462fac542170a81a9a206f3418dd8bc9e1f25d1d13dadef630e0fdf2880d71079808ebc49d36a7dbca7b5cdb76ad37b722c66b4b3d3efc8b5d2f35
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dbuild_static_lib=ON
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/easyloggingpp RENAME copyright)
