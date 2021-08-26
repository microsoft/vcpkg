vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF 4a21a1c0757083a16497fea27886f5f20ccdf334 # v0.4.56
    SHA512 68898a8ac15d5490f45676eabfbe0df9e45370a74c543a28909fd0d85fed48dfcf4bcd6ea2d01d1a036dd352e2e4e0b08c48c63ab2a2b477fe150b46a827136e
    HEAD_REF master
    PATCHES
        disable-error-4068.patch # This patch fixes dependency port compilation failure
        disable_warnings_as_errors.patch # Ref https://github.com/awslabs/aws-c-common/pull/798
        disable-internal-crt-option.patch # Disable internal crt option because vcpkg contains crt processing flow
        fix-cmake-target-path.patch # Shared libraries and static libraries are not built at the same time
        disable_outline_atomics.patch # Disables -moutline-atomics flag which is not supported for wasm32 and Android
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-c-common/cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-common
    ${CURRENT_PACKAGES_DIR}/lib/aws-c-common
    )

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
