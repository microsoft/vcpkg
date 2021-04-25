vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xsco/libdjinterop
    REF 0.14.6
    SHA512 3d05bc882ddc309a1b0d5e97572ede1aa826b662a19ffd8ee874c13ead668d1c3f14d59bf861ae3880588e1a9b94e4a92ccdbb5df71bfb7ffe28f57a1b123f18
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
