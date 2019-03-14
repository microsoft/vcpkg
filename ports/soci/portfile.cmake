include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF 3.2.3
    SHA512 8c597b37efe82c85e6d951f66cb0f818d2c12cb673914bc7b322bc0a9da676e6c02f221c9104fb06d1b4b02fed4e5a4fb872dd3370b9117f248c3b948faf4fb3
    HEAD_REF master
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/no-define-snprintf.patch"
            "${CMAKE_CURRENT_LIST_DIR}/find-libpqd.patch"
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
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
    OPTIONS
        -DSOCI_TESTS=OFF
        -DSOCI_CXX_C11=ON
        -DSOCI_LIBDIR:STRING=lib # This is to always have output in the lib folder and not lib64 for 64-bit builds
        -DLIBDIR:STRING=lib
        -DSOCI_STATIC=${SOCI_STATIC}
        -DSOCI_SHARED=${SOCI_DYNAMIC}
        ${_COMPONENT_FLAGS}

        -DWITH_MYSQL=OFF
        -DWITH_ORACLE=OFF
        -DWITH_FIREBIRD=OFF
        -DWITH_DB2=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/src/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/soci)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/soci/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/soci/copyright)

vcpkg_copy_pdbs()