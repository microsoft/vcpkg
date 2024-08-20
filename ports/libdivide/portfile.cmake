vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ridiculousfish/libdivide
    REF 5.0
    SHA512 89581efab63a0668405196d4d8188e03f3b87027e9014ef7238e1d79fe369d8abbca0e44b00cf02b00be29c272feb34c9b9290313596adbef9b46ae0715c29dd
    HEAD_REF master
    PATCHES
        no-werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBDIVIDE_SSE2=OFF
        -DLIBDIVIDE_AVX2=OFF
        -DLIBDIVIDE_AVX512=OFF
        -DLIBDIVIDE_NEON=OFF
        -DENABLE_VECTOR_EXTENSIONS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright) 
