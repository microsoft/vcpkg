vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO H-uru/libhsplasma
    REF 2327302a62b891f551b5f6daf899cf86997dce72 # 2022.05.19
    SHA512 89755e502e4a66a56013e3ff52c8d0c2350e5681be49c1b47f580591e3c3da24c587dee5af4f9524ea43f2d86f24ecef611d62d6045b293eb8d09cd5f0ac3d18
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
