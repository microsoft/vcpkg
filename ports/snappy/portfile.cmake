include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/snappy
    REF 1.1.7
    SHA512 32046f532606ba545a4e4825c0c66a19be449f2ca2ff760a6fa170a3603731479a7deadb683546e5f8b5033414c50f4a9a29f6d23b7a41f047e566e69eca7caf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSNAPPY_BUILD_TESTS=OFF
        -DCMAKE_DEBUG_POSTFIX=d)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Snappy)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/snappy)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snappy/COPYING ${CURRENT_PACKAGES_DIR}/share/snappy/copyright)
