if(NOT "feature-a" IN_LIST FEATURES AND NOT "feature-b" IN_LIST FEATURES AND NOT "feature-c" IN_LIST FEATURES)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        feature-a WITH_FEATURE_A
        feature-b WITH_FEATURE_B
        feature-c WITH_FEATURE_C
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/project"
    OPTIONS ${FEATURE_OPTIONS}
)

if("feature-a" IN_LIST FEATURES)
    vcpkg_cmake_build()
endif()

if("feature-b" IN_LIST FEATURES OR "feature-c" IN_LIST FEATURES)
    vcpkg_cmake_install()
endif()

if(NOT "feature-b" IN_LIST FEATURES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
    vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/project/LICENSE")
endif()
