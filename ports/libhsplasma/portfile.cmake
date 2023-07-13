vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO H-uru/libhsplasma
    REF 448ad712015c0b8a293af7bd56ab623dd2e6e131 # 2023.05.08
    SHA512 c08e7708f1a6e392075cc6eccbbf2ac932ce77d789ecb192e6805e478fe32f412c4b964494bdcc8574ed18c47b16c02e99b98994a63478ea6768ccedea6a3417
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
