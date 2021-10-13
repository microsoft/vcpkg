# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF 7404a4dd7697e188df5724ab95a7553d2fc404eb # v2.13.0
    SHA512 35ca098e783d771f3df611bce84e9b8207a6a5b72c492d2f3909977bc91a7c22bb262c34768b0d97ebfbdf12eeda0214064a8ea171e7bdda7b759f93ff346f45
    HEAD_REF master
    PATCHES rename-version.patch
)
file(RENAME "${SOURCE_PATH}/VERSION" "${SOURCE_PATH}/VERSION.txt")

if(DEFINED NANODBC_ODBC_VERSION)
    set(NANODBC_ODBC_VERSION -DNANODBC_ODBC_VERSION=${NANODBC_ODBC_VERSION})
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNANODBC_DISABLE_EXAMPLES=ON
        -DNANODBC_DISABLE_TESTS=ON
        -DNANODBC_ENABLE_UNICODE=OFF
        ${NANODBC_ODBC_VERSION}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
