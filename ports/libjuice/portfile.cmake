vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF v0.5.2
    SHA512 c96bf8d26a8f760ed0593d0e150a6dc410490daf8bab6c1f0abcce6082fbd71886ff6f966dc7031c1cb9c83ebd6e9dd5de9f61492f4265410a50465924b37027
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    nettle USE_NETTLE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNO_TESTS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/libjuice)
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
