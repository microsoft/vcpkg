include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cyan4973/xxHash
    REF a728fc9fe895460ff0e5f1efc2ce233d2095fd20
    SHA512 7795be00054d5f7abf4afab5912cc532bfc47f0bc8278cf09a44feb854f11e921d3d43e734efda1edbae0722450e4f9f02eeb5954220293eac930b4fa13ff737
    HEAD_REF dev
    PATCHES fix-arm-uwp.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake_unofficial
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xxhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xxhash/LICENSE ${CURRENT_PACKAGES_DIR}/share/xxhash/copyright)
