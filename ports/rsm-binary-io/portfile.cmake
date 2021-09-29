vcpkg_fail_port_install(ON_TARGET "OSX" "UWP")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ryan-rsm-McKenzie/binary_io
    REF 2.0.2
    SHA512 4b7e725d9143d37481b4a7e4e101c88c3b73628dd2882fa23ef10a602f8a6ca79de111138237d4dd6fc09d1df863b91a949782961f5623fcac1e324b2e301121
    HEAD_REF main
)

if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "Build ${PORT} requires at least gcc 10.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME binary_io
    CONFIG_PATH "lib/cmake/binary_io"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
