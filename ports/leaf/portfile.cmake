include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zajo/leaf
    REF 0.2.2
    SHA512 200a78e33fa919fbf996cfa5715f166e194b87776de79dec4c23d7a60b1f1e1c9db699f3d94d17b52c655e802ea63e1e6539538b180ecaafbfcf106b280b5c1f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/leaf RENAME copyright)
