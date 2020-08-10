vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF c0bafd67140e8c6f4f585c1077f2fd89102e4582 # v2020.02.03.00
    SHA512 7db706ffdd79f6d753c5530eb67646747d1e7b8b380387f34bd1fc7a06b289a68a6bb4c13faa74e108d4dede72bb2d993d7ad8f60fabcfb3b48abbf4326291c2
    HEAD_REF master
    PATCHES
        find-zlib.patch
)

# Prefer installed config files
file(REMOVE
    ${SOURCE_PATH}/fizz/cmake/FindGflags.cmake
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)