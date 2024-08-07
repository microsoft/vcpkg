vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF "v${VERSION}"
    SHA512 8a7e26daf05219ee2e490052b36be732bad35d570b66e9c08c36e4364ba183a511ea01e4444a8bf94dffd764a3f45f38900f7f4e26a531568b6c3adbd2bd7b53
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        nettle USE_NETTLE
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND arg_OPTIONS "-DJUICE_STATIC=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${arg_OPTIONS}
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
