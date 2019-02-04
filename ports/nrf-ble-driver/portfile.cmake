include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NordicSemiconductor/pc-ble-driver
    REF v4.0.0
    SHA512 0a8819e23680c7b3876ea4c3b2de8474ff90768797831d1a4e413997903598ca0532eead27e023b85a800eac249d02e8c1314fc271c041b043ca882a30d62c0d
    HEAD_REF hex/d17406fad44c4a96d8ef376b35c6a59fad7180d2
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DDISABLE_TESTS= -DDISABLE_EXAMPLES=
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
