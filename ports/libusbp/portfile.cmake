if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(
"${PORT} currently requires the following libraries from the system package manager:
    libudev-dev
These can be installed on Ubuntu systems via sudo apt install libudev-dev"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pololu/libusbp
    REF "${VERSION}"
    SHA512 3705ab40b65323eab788592b1b5e1cd94ef1d7ee55fb0f2919013a8bdb488eb83e257623a8be8c5230a74eaea1c0fd8a5926a8a399f0d2f6eebcd82ec0a01c4d
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
