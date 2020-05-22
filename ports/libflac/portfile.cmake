vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/flac
    REF ce6dd6b5732e319ef60716d9cc9af6a836a4011a
    SHA512 d0d3b5451f8d74aa0a0832fbe95cca55597ce9654765a95adaac98ecd0da9e803b98551a40a3fb3fd5b86bc5f40cd1a791127c03da5322e7f01e7fa761171a21
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/uwp-library-console.patch"
        "${CMAKE_CURRENT_LIST_DIR}/uwp-createfile2.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_TESTING=OFF)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/FLAC/cmake
    TARGET_PATH share/FLAC
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# This license (BSD) is relevant only for library - if someone would want to install
# FLAC cmd line tools as well additional license (GPL) should be included
file(COPY ${SOURCE_PATH}/COPYING.Xiph DESTINATION ${CURRENT_PACKAGES_DIR}/share/libflac)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libflac/COPYING.Xiph ${CURRENT_PACKAGES_DIR}/share/libflac/copyright)
