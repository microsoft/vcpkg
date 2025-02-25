if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cieslarmichal/faker-cxx
    REF "v${VERSION}"
    SHA512 0ad3550d45df2adda70ad64fc1afffc2d39f6644e46029b6b3f0fd42eed071b55daeee9da7456b8b75e1da566bd0d1605518722b2831dba31bf9787506ecfa9d
    HEAD_REF master
    PATCHES
        CMakeLists.txt.patch
        FormatHelper.h.patch
        Helper.h.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_FAKER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/faker-cxx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
