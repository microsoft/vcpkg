vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/snappy
    REF 537f4ad6240e586970fe554614542e9717df7902 # 1.1.8
    SHA512 555d3b69a6759592736cbaae8f41654f0cf14e8be693b5dde37640191e53daec189f895872557b173e905d10681ef502f3e6ed8566811add963ffef96ce4016d
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
