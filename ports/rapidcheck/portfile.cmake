vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emil-e/rapidcheck
    REF 57e9d30b15984ae2601749828243ebc426e0dca0
    SHA512 b2651affa322029d68d64a09b777ef11078df2bfea2b9cf10c0cb6a4e2a7dc72a60c4b526e79c7cbd75a72aaf3ce942e02c94b8243702ab5d9a6008fc8bdbd3a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRC_INSTALL_ALL_EXTRAS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT}/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
