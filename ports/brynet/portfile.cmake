include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IronsDu/brynet
    REF v1.0.2
    SHA512 b07ceb858ed125959b3901415d6099939acf51a194950de8c65f063b6462a0ab424494659aedd889378bd4388cc9e71a0aedcb30108b6c2eef4d5e6ebea2cce8
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brynet)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/brynet/LICENSE ${CURRENT_PACKAGES_DIR}/share/brynet/copyright)
