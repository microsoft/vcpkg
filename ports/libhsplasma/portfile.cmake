vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO H-uru/libhsplasma
    REF e435db76f86a0258ccd6f62a8bcd1f8b42d4f22d #2021.06.08
    SHA512 ebd53633f22662793613c689b5a07f6149ed2b437c42a024e7c14a18d4411356edb11c95c08e1215dde443988fd1e4bcdd8d35fc30ca2545f507d6a61565cc69
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        net ENABLE_NET
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_PHYSX=OFF
        -DENABLE_PYTHON=OFF
        -DENABLE_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME HSPlasma CONFIG_PATH share/cmake/HSPlasma)

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
