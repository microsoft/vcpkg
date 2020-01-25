set(OATPP_VERSION "0.19.12")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

message(STATUS "Building oatpp-curl")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-curl
    REF ef94f5b044cd2cec29736697adbc9d0e686d413e # 0.19.12
    SHA512 7616450a530d63e1512b6cc8c2aa1979473b510af0b97f904b6f4a062902b5e0c07a0d18d9d1c022d5c5f073bec7a31565c050f07f90d4af27c665f9d7e1654c
    HEAD_REF master
    PATCHES "curl-submodule-no-pkg-config-in-vcpkg.patch"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "ON")
else()
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
        "-DBUILD_SHARED_LIBS:BOOL=${OATPP_BUILD_SHARED_LIBRARIES_OPTION}"
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-curl-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
