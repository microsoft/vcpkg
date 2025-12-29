vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adityarao2005/WebCraft
    REF v${VERSION}
    SHA512 1c0c5de6a6a42b9a6366a633c6dd00008fc1c631da6cda146ae952c499b8a11028af0f8dad2a1c6c3a51119a6bec44ad5087b6128c015910957c661ea52bee7c
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
