vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF "v${VERSION}"
    SHA512 5696ada382b70e5e8edc123c021cc1bf48a091253e20c705d1a23de3e5a9a240c138090228d02c5937a2418202e10216fafce4579195d5c2c92e7f7be107e622
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        nettle USE_NETTLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNO_TESTS=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME libjuice CONFIG_PATH lib/cmake/LibJuice)
vcpkg_fixup_pkgconfig()

file(READ "${CURRENT_PACKAGES_DIR}/share/libjuice/LibJuiceConfig.cmake" DATACHANNEL_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libjuice/LibJuiceConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
${DATACHANNEL_CONFIG}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
