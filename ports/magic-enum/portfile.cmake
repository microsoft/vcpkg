# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/magic_enum
    REF v0.7.0
    SHA512 f56c081063846b87e8b811babe9a0e961efd29bef52359e14cb33773f8393640196c0808e201800c3adb82d0bf362d1f941e31df0fc3739d35a367f918409822
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
        -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
        -DMAGIC_ENUM_OPT_INSTALL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/magic_enum TARGET_PATH share/magic_enum)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
