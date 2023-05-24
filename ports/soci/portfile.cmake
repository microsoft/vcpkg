vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF "v${VERSION}"
    SHA512 d501f55e7e7408e46b4823fd8a97d6ef587f5db0f5b98434be8dfc5693c91b8c3b84a24454279c83142ab1cd1fa139c6e54d6d9a67397b2ead61650fcc88bcdb
    HEAD_REF master
    PATCHES
        fix-dependency-libmysql.patch
        export-include-dirs.patch
        fix-mysql-feature-error.patch # https://bugs.mysql.com/bug.php?id=85131
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOCI_DYNAMIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SOCI_STATIC)

# Handle features
set(_COMPONENT_FLAGS "")
foreach(_feature IN LISTS ALL_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Turn "-DWITH_*=" ON or OFF depending on whether the feature
    # is in the list.
    if(_feature IN_LIST FEATURES)
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=ON")
    else()
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=OFF")
    endif()

    if(_feature MATCHES "mysql")
        set(MYSQL_OPT "-DMYSQL_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/mysql")
    endif()
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOCI_TESTS=OFF
        -DSOCI_CXX11=ON
        -DSOCI_STATIC=${SOCI_STATIC}
        -DSOCI_SHARED=${SOCI_DYNAMIC}
        ${_COMPONENT_FLAGS}
        ${MYSQL_OPT}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SOCI)

if ("mysql" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/SOCIConfig.cmake"
        "# Create imported target SOCI::soci_mysql"
        "\ninclude(CMakeFindDependencyMacro)\nfind_dependency(libmysql)\n# Create imported target SOCI::soci_mysql"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
