include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF poco-1.9.0-release
    SHA512 de2346d62b2e89ba04abe62a83f6ede7a496e80bcbe53a880a1aa8e87a8ebd9a430dd70fdc6aada836bb1021c6df21375fd0cbcf62dbb6e29a2f65d6d90cf2b9
    HEAD_REF master
    PATCHES
        config_h.patch
        find_pcre.patch
        foundation-public-include-pcre.patch
        fix-static-internal-pcre.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" POCO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" POCO_MT)

if("mysql" IN_LIST FEATURES)
    # enabling MySQL support
    set(MYSQL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/mysql")
    set(MYSQL_LIB "${CURRENT_INSTALLED_DIR}/lib/libmysql.lib")
    set(MYSQL_LIB_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/libmysql.lib")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPOCO_STATIC=${POCO_STATIC}
        -DPOCO_MT=${POCO_MT}
        -DENABLE_SEVENZIP=ON
        -DENABLE_TESTS=OFF
        -DPOCO_UNBUNDLED=ON # OFF means: using internal copy of sqlite, libz, pcre, expat, ...
        -DMYSQL_INCLUDE_DIR=${MYSQL_INCLUDE_DIR}
    OPTIONS_RELEASE
        -DMYSQL_LIB=${MYSQL_LIB}
    OPTIONS_DEBUG
        -DMYSQL_LIB=${MYSQL_LIB_DEBUG}
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/cpspc.exe")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/cpspc.exe ${CURRENT_PACKAGES_DIR}/tools/cpspc.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/f2cpsp.exe ${CURRENT_PACKAGES_DIR}/tools/f2cpsp.exe)
else()
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/cpspc ${CURRENT_PACKAGES_DIR}/tools/cpspc)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/f2cpsp ${CURRENT_PACKAGES_DIR}/tools/f2cpsp)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE 
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE 
        ${CURRENT_PACKAGES_DIR}/bin/cpspc.pdb
        ${CURRENT_PACKAGES_DIR}/bin/f2cpsp.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.pdb)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Poco)

# copy license
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/poco)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/poco/LICENSE ${CURRENT_PACKAGES_DIR}/share/poco/copyright)
