vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO epezent/implot
    REF v0.3
    SHA512 28d25a76b725879ad796249edc87910fec721fcd43b80171947e00c4983a945f82f2b555f1794882b79c96a4497da982dc45695fed5eedcf6009f87c05576817
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DIMPLOT_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)