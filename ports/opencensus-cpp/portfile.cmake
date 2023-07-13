vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO census-instrumentation/opencensus-cpp
    REF 62d8281899a1cfd1084793f64295329a6b5d22b3 # 2021-08-26
    SHA512 35df40d7e5ce933384fe6ba4ac2d704e0801ac47765fca97ea3f8d787886abe5c588855c3aac5745f047c1c8f2047e1f69b62340dd702042a61c3dc430ca36b4
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test BUILD_TESTING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
