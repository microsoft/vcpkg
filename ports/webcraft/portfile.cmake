vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adityarao2005/WebCraft
    REF v${VERSION}
    SHA512 d598d6303fefa1b18e7effb57da99e353a898817bde917588d103aabe0662eea07a3647dc9338c3cd6ba2d048423b7640cbb396f5fd42dd4f7997136b4bcb236
    HEAD_REF main
    PATCHES
        fix-concurrentqueue.patch
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

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/include/webcraft/async/README.md"
    "${CURRENT_PACKAGES_DIR}/include/webcraft/async/asyncruntime.drawio.svg"
    "${CURRENT_PACKAGES_DIR}/include/webcraft/async/io/README.md"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
