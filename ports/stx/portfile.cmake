vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lamarrr/STX
    REF 03ee6533944b5719e05ef65d920559084fd722a1
    SHA512 0763a542c78163a21fd66e35fd97f15e9381c0d61e15f0a53e20c950861d8176f5d2fb476839cf30fc03ba2378d503b2b7643204dfbf582bbb806fea2eab74c0
    HEAD_REF master
    PATCHES
        "CMakeLists.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
     backtrace    STX_ENABLE_BACKTRACE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSTX_BUILD_DOCS=OFF
        -DSTX_BUILD_BENCHMARKS=OFF
        -DSTX_BUILD_SHARED=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/stx)
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)
