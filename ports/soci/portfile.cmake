include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF 3742c894ab8ba5fd51b6a156980e8b34db0f3063 #version 4.0.0 commit on 2019.11.10
    SHA512 27950230d104bdc0ab8e439a69c59d1b157df373adc863a22c8332b8bb896c2a6e3028f8343bb36b42bf9ab2a2312375e20cbdeca7f497f0bb1424a4733f0c9c
    HEAD_REF master
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

        -DWITH_MYSQL=OFF
        -DWITH_ORACLE=OFF
        -DWITH_FIREBIRD=OFF
        -DWITH_DB2=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/SOCI)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
