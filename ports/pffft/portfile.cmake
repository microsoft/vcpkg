vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpommier/pffft
    REF ed78751d751e51bbd94c41d24f748b400f272d69
    SHA512 44f65c7f7e5b71f549dca2e03d58b1fd64e698858f79e4c2833a9ae3dff8a835cf9d5e14be2341c6370f800012cb69b05b9226d6918b12e67f7f7e81ed8e9ad4
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")