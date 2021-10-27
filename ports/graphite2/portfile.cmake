vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO silnrsi/graphite
    REF 92f59dcc52f73ce747f1cdc831579ed2546884aa # 1.3.14
    SHA512 011855576124b2f9ae9d7d3a0dfc5489794cf82b81bebc02c11c9cca350feb9fbb411844558811dff1ebbacac58a24a7cf56a374fc2c27e97a5fb4795a01486e
    HEAD_REF master
    PATCHES disable-tests.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDISABLE_TESTS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
