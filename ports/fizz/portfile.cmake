vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF c44af5a6dfb37b8448117a3ce01e5b9bb3ff1c40 #2019.10.21.00
    SHA512 77ed1b911bd6b9b08d34138573d47567a6ec3b2c7c48f9e83312c1b832f79a2ec5210be735408d879c5fe86122f67bc2bd8bfc2fdc89809d3a28c84db5bb3897
    HEAD_REF master
    PATCHES
        find-zlib.patch
        fix-build_error.patch
)

# Prefer installed config files
file(REMOVE
    ${SOURCE_PATH}/fizz/cmake/FindGflags.cmake
    ${SOURCE_PATH}/fizz/cmake/FindLibevent.cmake
    ${SOURCE_PATH}/fizz/cmake/FindGlog.cmake
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/fizz"
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/fizz)
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake _contents)
string(REPLACE "lib/cmake/fizz" "share/fizz" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake
"include(CMakeFindDependencyMacro)
find_dependency(folly CONFIG)
find_dependency(ZLIB)
${_contents}")

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fizz RENAME copyright)
