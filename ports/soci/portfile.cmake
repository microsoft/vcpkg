vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF 99e2d567161a302de4f99832af76e6d3b75b68e6 #version 4.0.2 
    SHA512 d08d2383808d46d5e9550e9c7d93fb405d9e336eb38d974ba429e5b9446d3af53d4e702b90e80c67e298333da0145457fa1146d9773322676030be69de4ec4f4
    HEAD_REF master
    PATCHES
        fix-dependency-libmysql.patch
        export-include-dirs.patch
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
        set(MYSQL_OPT -DMYSQL_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/mysql)
    endif()
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSOCI_TESTS=OFF
        -DSOCI_CXX11=ON
        -DSOCI_LIBDIR:STRING=lib # This is to always have output in the lib folder and not lib64 for 64-bit builds
        -DLIBDIR:STRING=lib
        -DSOCI_STATIC=${SOCI_STATIC}
        -DSOCI_SHARED=${SOCI_DYNAMIC}
        ${_COMPONENT_FLAGS}
        ${MYSQL_OPT}
        -DWITH_ORACLE=OFF
        -DWITH_FIREBIRD=OFF
        -DWITH_DB2=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

if ("mysql" IN_LIST FEATURES)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/${PORT}/SOCIConfig.cmake
        "# Create imported target SOCI::soci_mysql"
        "\ninclude(CMakeFindDependencyMacro)\nfind_dependency(libmysql)\n# Create imported target SOCI::soci_mysql"
    )
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
