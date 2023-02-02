vcpkg_download_distfile(WINDOWS_SYMBOLS_PATCH
    URLS https://github.com/ginkgo-project/ginkgo/commit/7481b2fffb51d73492ef9017045450b29b820f81.diff
    FILENAME 7481b2fffb51d73492ef9017045450b29b820f81.diff
    SHA512 f81c57aacc30680383ccfb21ca08987d8ea19a23c0c7bbc5ae590c3c7eca4eed72cea84410357e080e5bb35f08f6b57834b3cdace6d91cc3fde0a1930aa4270a
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ginkgo-project/ginkgo
    REF v1.4.0
    SHA512 9bfcb2c415c7a1a70cf8e49f20adf62d02cab83bb23b6fcecfeaeeb322b2d4e1ad8d8fa6582735073753f9a05eac8688b9bd1ff1d4203957c1a80702d117e807
    HEAD_REF master
    PATCHES
        ${WINDOWS_SYMBOLS_PATCH}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    openmp    GINKGO_BUILD_OMP
    cuda      GINKGO_BUILD_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGINKGO_BUILD_REFERENCE=ON
        -DGINKGO_BUILD_TESTS=OFF
        -DGINKGO_BUILD_EXAMPLES=OFF
        -DGINKGO_BUILD_HIP=OFF
        -DGINKGO_BUILD_DPCPP=OFF
        -DGINKGO_BUILD_HWLOC=OFF
        -DGINKGO_BUILD_BENCHMARKS=OFF
        -DGINKGO_DEVEL_TOOLS=OFF
        -DGINKGO_SKIP_DEPENDENCY_UPDATE=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DGinkgo_NAME=ginkgo
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Ginkgo)
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ginkgo/GinkgoConfig.cmake" [[string(REPLACE "lib/cmake/Ginkgo" "" GINKGO_INSTALL_PREFIX "${GINKGO_CONFIG_FILE_PATH}")]] "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ginkgo/GinkgoConfig.cmake" "GINKGO_INSTALL_PREFIX" "_IMPORT_PREFIX")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ginkgo/GinkgoConfig.cmake" "/lib/cmake/Ginkgo\"" "/share/ginkgo\"")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ginkgo/GinkgoConfig.cmake" "/lib/cmake/Ginkgo/Modules\"" "/share/ginkgo/Modules/Modules\"")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ginkgo/GinkgoConfig.cmake" "\"${SOURCE_PATH}/cmake/Modules/\"" "")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ginkgo" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ginkgo")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
