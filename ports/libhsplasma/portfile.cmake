vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO H-uru/libhsplasma
    REF afd9c46fa72afbbaf5260800ecfde0704ba2a475
    SHA512 21774b465ede7fe5e44df4470ed6867977ac9249400ba6d0bed33fd0e856d467de1afe79afb8a4dc6145eef21c5a3f79590b5cfa3ea1337cc355ca8f3bf1a11c
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    net ENABLE_NET
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_PHYSX=OFF
        -DENABLE_PYTHON=OFF
        -DENABLE_TOOLS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/cmake/HSPlasma
    TARGET_PATH share/HSPlasma
)

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
