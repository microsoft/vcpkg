vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusbancila/stduuid
    REF v1.2.2
    SHA512 30970c25992e1ba35d96e3b2fc8530466c1070b8b913b8c37e9f698f39121a5a74361e2c4db4c2ba2feddb0ce9b2f14b78c4761cdac09b89a6a0117b179b08a7
    HEAD_REF master
    PATCHES
        fix-install-directory.patch
        fix-gsl-polyfill.patch
        fix-libuuid-dependency.patch
)

# the debug build is not necessary, because stduuid deployed files are header-only
set(VCPKG_BUILD_TYPE release)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        system-gen UUID_SYSTEM_GENERATOR
    INVERTED_FEATURES
        gsl-span UUID_USING_CXX20_SPAN
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DUUID_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

if("gsl-span" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/stduuid/uuid.h" "#ifdef __cpp_lib_span" "#if 0")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/stduuid/uuid.h" "#include <span>" "#include <gsl/span>")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/stduuid/uuid.h" "#ifdef __cpp_lib_span" "#if 1")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
