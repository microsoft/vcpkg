vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")
vcpkg_fail_port_install(ON_TARGET "linux" "uwp" "osx")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ttauri-project/ttauri
    REF v0.5.0
    SHA512 946c8b7fbd030235d06fff3e100c6be15c2dd360306c674906eb395067642ea38551290ebf4d2c398798219b5c0711eeaecb57bc5021db9f91ec343baab64171
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTT_BUILD_TESTS=OFF
        -DTT_BUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
