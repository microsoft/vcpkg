vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusbancila/stduuid
    REF "v${VERSION}"
    SHA512 3d2fb21f680fb12559642d6787a5744d4f4fb48a6284bfef77537cb51f9bdbbe271b24a8c3bb1f954b4c845145f22c6d89a09e663df2f96a2e24d1d6f22fdf22
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

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DUUID_BUILD_TESTS=OFF
        -DUUID_ENABLE_INSTALL=ON
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

if("gsl-span" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/stduuid/uuid.h" "#ifdef __cpp_lib_span" "#if 0")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/stduuid/uuid.h" "#include <span>" "#include <gsl/span>")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/stduuid/uuid.h" "#ifdef __cpp_lib_span" "#if 1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
