# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW) # According to the CMakeLists.txt
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF 7404a4dd7697e188df5724ab95a7553d2fc404eb # v2.13.0
    SHA512 35ca098e783d771f3df611bce84e9b8207a6a5b72c492d2f3909977bc91a7c22bb262c34768b0d97ebfbdf12eeda0214064a8ea171e7bdda7b759f93ff346f45
    HEAD_REF master
    PATCHES
        rename-version.patch
        add-missing-include.patch
        find-unixodbc.patch
        fix_clang-cl.patch
)
file(REMOVE "${SOURCE_PATH}/VERSION")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "boost" NANODBC_ENABLE_BOOST
        "unicode" NANODBC_ENABLE_UNICODE)

if(DEFINED NANODBC_ODBC_VERSION)
    set(NANODBC_ODBC_VERSION -DNANODBC_ODBC_VERSION=${NANODBC_ODBC_VERSION})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANODBC_DISABLE_EXAMPLES=ON
        -DNANODBC_DISABLE_TESTS=ON
        ${NANODBC_ODBC_VERSION}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
