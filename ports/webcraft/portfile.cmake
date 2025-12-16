vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adityarao2005/WebCraft
    REF v${VERSION}
    SHA512 8ebdd1eb2976457269cc37f1e75c9fdad46460b3ca2314dd138889488d6b0c940bf6659dfd16cdd06dc399d507a9952940c360e4298f614cc474e08eecc7b2c7
    HEAD_REF main
)

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWEBCRAFT_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
	PACKAGE_NAME WebCraft
	CONFIG_PATH share/WebCraft
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
