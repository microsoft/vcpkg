vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artem-ogre/CDT
    REF "${VERSION}"
    SHA512 0ecadd96ecaf6e7799065e89beda706e4018f9ad6a2076604a7b84c57225ac7231f9438932cb63e967ae0dfe72361aee2f286794cfb6303ec894f4948e4e611d
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "64-bit-index-type"     CDT_USE_64_BIT_INDEX_TYPE
        "as-compiled-library"   CDT_USE_AS_COMPILED_LIBRARY
)

if (NOT CDT_USE_AS_COMPILED_LIBRARY)
    set(VCPKG_BUILD_TYPE "release") # header-only
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/CDT"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if (CDT_USE_AS_COMPILED_LIBRARY)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
