vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")
vcpkg_fail_port_install(ON_TARGET "linux" "uwp" "osx")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ttauri-project/ttauri
    REF v0.4.0
    SHA512 85a15b9d9b1b98b5811a5833415d1ab8a34b39e055959038507b3d873c3544b5193817ce8d474ffc4f8b7ad1602bc0f6401e3565225cf58a90ddee3f9f0a0731
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
