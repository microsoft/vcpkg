# Without static-shim: INTERFACE only — Release and Debug are identical.
# With static-shim: compiled code is produced — both variants are needed.
if(NOT "static-shim" IN_LIST FEATURES)
    set(VCPKG_BUILD_TYPE release)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/snmalloc
    REF "${VERSION}"
    SHA512 eb49ebd8eea6d7639cbcedb795469c8ed47f4324ad86cec50ddca76c187f612b5588df6d3316c5d292ead31e96956f5556611fde8fee38f436d5e97b1449a979
    HEAD_REF main
)

# NOTE: The CI overlay port (see .github/workflows/main.yml, vcpkg-integration)
# uses sed to extract from this line onwards to build a portfile that points at
# the local checkout. If you reorder code above this line, update the sed
# pattern there.
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "static-shim" SNMALLOC_STATIC_LIBRARY
    INVERTED_FEATURES
        "static-shim" SNMALLOC_HEADER_ONLY_LIBRARY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSNMALLOC_BUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME snmalloc
    CONFIG_PATH share/snmalloc
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
