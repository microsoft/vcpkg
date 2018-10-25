include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-RTPS
    REF b1779b608c7b5b2dcb101728f4213c58bdde74ee # waiting for next release
    SHA512 9ec4a1e41296df1c0bc00926d925e0947602fabb68e9b28311e92739b0e1909a2993b15fc05eb31aeb9842ed50127f8d56571d09e57dd64ac6f37d0fed6cea73
    HEAD_REF master
    PATCHES fix-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/fastrtps/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/examples)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/examples)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/fastrtps)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/fastrtps)

file(RENAME ${CURRENT_PACKAGES_DIR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/fastrtps/copyright)
