vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF 1c40fde31b5eff8a05f928497429bffe7425b4fd # v2020.10.19.00
    SHA512 9e0de756855941c377f2a52d9b751e6ae066c8d8ae4e7a06211b2537a039e533cbc782cbce947cb703d7bd4c5cb5fb4420e71eeafdcb5f1264d788ca3eb0b76d
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/fizz/tool/test" "${CURRENT_PACKAGES_DIR}/include/fizz/util/test")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)