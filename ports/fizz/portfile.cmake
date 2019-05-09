include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF v2019.05.06.00
    SHA512 c2f832e1f402eef86d9066d7c59a7801d7f1ede904b70005526b2be6cb554cc4b530b5a05575c9511953f5458108e3380b12e0a4a9b05ec14000d7b83d468ca8
    HEAD_REF master
    PATCHES depend-zlib.patch
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
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/fizz")
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake _contents)
string(REPLACE "lib/cmake/fizz" "share/fizz" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake "${_contents}")

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fizz RENAME copyright)
