vcpkg_fail_port_install(ON_TARGET Android FreeBSD Linux OSX UWP)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fancycode/MemoryModule
    REF 5f83e41c3a3e7c6e8284a5c1afa5a38790809461
    SHA512 6d42bd80dfeaf7bc662adafe7d6a7d7301eff5ea53bb59fce7e9c1a6ee22d31d2ab5696afc0a92c1501aa4161a60366418bfc3bed7ed2dcb6cae24243f4fa6d4
    HEAD_REF master
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    unicode UNICODE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DTESTSUITE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_build_cmake(TARGET MemoryModule)

file(INSTALL ${SOURCE_PATH}/MemoryModule.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/MemoryModule.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/MemoryModule.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
