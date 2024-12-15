if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ginkgo-project/ginkgo
    REF "v${VERSION}"
    SHA512 9a52534cf19f908f776ed54b43791e621a9bd5da1fec93a4f035cf4535ddb0ce9cb9e6623ee57c631c76012b4f3ed5066ec731dc3ecac722f6b5d705ec7fd4c7
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    openmp    GINKGO_BUILD_OMP
    cuda      GINKGO_BUILD_CUDA
    mpi       GINKGO_BUILD_MPI
    half      GINKGO_ENABLE_HALF
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
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Ginkgo)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ginkgo" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ginkgo")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/CMakeFiles")
