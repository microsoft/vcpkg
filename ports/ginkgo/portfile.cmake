vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ginkgo-project/ginkgo
    REF v1.5.0
    SHA512 5b76e240d27c24cbcd7292638da4748cfba39494784894fcffce63e0aff2cd7c5c24155ccd6fc6cdfab413b627afd1b2f9dc09a58d1e01bd4d5a25169f357041
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    openmp    GINKGO_BUILD_OMP
    cuda      GINKGO_BUILD_CUDA
    mpi       GINKGO_BUILD_MPI
)

set(ADDITIONAL_FLAGS)

if(VCPKG_TARGET_IS_WINDOWS)
    set(ADDITIONAL_FLAGS "-DCMAKE_CXX_FLAGS_DEBUG='/MDd /Zi /Ob1 /O1 /Od /RTC1'")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
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
        ${ADDITIONAL_FLAGS}
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
