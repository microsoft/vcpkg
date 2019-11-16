include(vcpkg_common_functions)

#the port produces some empty dlls when building shared libraries, since some components do not export anything, breaking the internal build itself
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RamadanAhmed/DBow3
    REF master
    SHA512 280c76c7c547908fd133f118e1d17fe0faed87b70f61df3cd01964bd7ef33bef10dfc79d6cab8aaaf2edbfc063de0b5ad3fd80e116eab0300f1cbab86d0e38b2
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_SIMD=ON
        -DUSE_OPENCV_CONTRIB=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake/DBow3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/DBow3 RENAME copyright)
vcpkg_copy_pdbs()