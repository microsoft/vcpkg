vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-socket
    REF "v${VERSION}"
    SHA512 d5e4bca03f6ccf0fd49df20917bb1f33408c03c2beb2a1f5c9bb43a6211151364706d43c0b004a0dc5184f38482bf67cc244792675b01d81c896a5d1789e20ce
    HEAD_REF main
)

# On Windows, only static library is supported (shared has no exports)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_STATIC ON)
    set(BUILD_SHARED OFF)
else()
    set(BUILD_STATIC OFF)
    set(BUILD_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_SOCKET_EXAMPLES=OFF
        -DBUILD_SLICK_SOCKET_TESTING=OFF
        -DBUILD_SLICK_SOCKET_STATIC_LIBS=${BUILD_STATIC}
        -DBUILD_SLICK_SOCKET_SHARED_LIBS=${BUILD_SHARED}
    MAYBE_UNUSED_VARIABLES
        BUILD_SLICK_SOCKET_STATIC_LIBS
        BUILD_SLICK_SOCKET_SHARED_LIBS
)

vcpkg_cmake_install()

# Fix up CMake config files before removing lib directory
vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick-socket
    CONFIG_PATH lib/cmake/slick-socket
)

# Remove duplicate headers from debug build
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    # Header-only library in linux and macos
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
endif()

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
