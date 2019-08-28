
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO silnrsi/graphite
    REF b45f9b271214b95f3b42e5c9863eae4b0bfb7fd7
    SHA512 5bd1052c1e21ab523ce17804b7123858d17ca9893cbd972f0af58119c5419d771df13d374569a14dd82605536674d9b1a4787300eac4bd89a177a40df5a05282
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

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphite2)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphite2 RENAME copyright)
