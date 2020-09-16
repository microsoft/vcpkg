vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/upb
    REF  7338facddb8ce405fe7a0a52a6061a1e7c823279
    SHA512 a2ece65612ca7c3cdc7b79994aa488623e5ce4227988611ab60724fae5dc7ba9311363bf5c73f6c74910a6b91392e0a231c28f0b2f4c8cc2c4d4328ed33bc265
    HEAD_REF master
    PATCHES
        add-cmake-install.patch
        fix-uwp.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    # empty folder
    ${CURRENT_PACKAGES_DIR}/include/upb/bindings/lua/upb
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
