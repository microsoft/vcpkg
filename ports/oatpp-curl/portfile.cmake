set(OATPP_VERSION "1.2.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-curl
    REF b7c0507e286fbc55ccbbb4a2604f6c46d3a86525 # 1.2.0
    SHA512 274aaf34733ab70b148182332db493157ed8c87e093d09bf7dcbd9c89034dab9a97f05ba0887459a8a0ed80b2c2248c253b1ff8c933e196a6ecee11546a4488b
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
