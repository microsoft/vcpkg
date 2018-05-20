include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF 6eb1a3e9775ab7cdbf0f7f5aa5891792313cd8d9
    SHA512 0d0127e422934c5ac707184b519b7682cb67d1480ebecf56520d085c9d29381075c1e2f7bfd8f5b7873ce3cc8ce35ba793e06f0c1f8bb506a83949cd27d15015
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOCI_DYNAMIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SOCI_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSOCI_TESTS=OFF
        -DSOCI_CXX_C11=ON
        -DSOCI_LIBDIR=lib # This is to always have output in the lib folder and not lib64 for 64-bit builds
        -DSOCI_STATIC=${SOCI_STATIC}
        -DSOCI_SHARED=${SOCI_DYNAMIC}

        -DWITH_BOOST=ON
        -DWITH_SQLITE3=ON

        -DWITH_MYSQL=OFF
        -DWITH_ODBC=OFF
        -DWITH_ORACLE=OFF
        -DWITH_POSTGRESQL=OFF
        -DWITH_FIREBIRD=OFF
        -DWITH_DB2=OFF
)

vcpkg_install_cmake()

file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/SOCI.cmake ${CURRENT_PACKAGES_DIR}/cmake/SOCIConfig.cmake)

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/soci)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/soci/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/soci/copyright)

vcpkg_copy_pdbs()