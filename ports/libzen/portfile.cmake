if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/ZenLib
    REF 65458b340378ecfddd0fa14359a3c57c79257b3d
    SHA512 3f76b78f813518bbfb82f2b608193e23582911bf6d5b83e1a484476d371e9296019ee60e8d4905d72f3d3ba51a0052d24574206c8bd22ccbeeeaf33f68b5c8f8
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Project/CMake"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DCMAKE_REQUIRE_FIND_PACKAGE_PkgConfig=1
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME zenlib)
vcpkg_fixup_pkgconfig()
if(NOT VCPKG_BUILD_TYPE AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzen.pc" " -lzen" " -lzend")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
