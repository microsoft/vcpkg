if(VCPKG_TARGET_IS_LINUX)
    message(
"${PORT} currently requires the following libraries from the system package manager:
    libudev-dev
These can be installed on Ubuntu systems via:
    sudo apt install libudev-dev"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Yubico/libfido2
    REF ${VERSION}
    SHA512 97932ca1a9f8d1bb3cb4b4a8d56ef70085d19ad2bd27c67944fa17ed033bfa45d28d7ad3fa318723e79b17ef5a882ac4f999ad8a6b9965c58665d99c4da7b5ee
    HEAD_REF main
    PATCHES
        dependencies.diff
        flags.diff
)

vcpkg_find_acquire_program(PKGCONFIG)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_MANPAGES=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
