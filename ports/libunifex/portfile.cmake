vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookexperimental/libunifex
    REF 070435602799b3bbbf0eb9d1973e422462c85726
    #REF e36b43834329acc75f99910316d3ecec15c0f665
    SHA512 e7599cb36db455f1d89c9a26b9f9ccdaa9060a9b2cc841023df3cdbe69b46c8c393fa648b846e6d8f4f2bef0de76c8e3a8d32971ba5e1dc34b4ce09995444c09 
    #SHA512 58f738b49d18982fd3916500c78e8090a266738ec4a8ba416b004fa2c7db718db5ce0e27f5e4e22eaddcc27c8d1618bcb2bc080eee1a31d98543e2595ccc1135
    HEAD_REF master
    PATCHES
        fix-install.patch
        allow-warnings.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test    BUILD_TESTING
        test    UNIFEX_BUILD_EXAMPLES
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unifex CONFIG_PATH lib/cmake/unifex)
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/unifex/config.hpp.in"
)
if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/unifex/linux")
elseif(VCPKG_TARGET_IS_LINUX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/unifex/win32")
endif()
