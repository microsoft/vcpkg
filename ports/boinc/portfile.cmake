vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
string(REGEX REPLACE "^([0-9]*[.][0-9]*)[.].*" "\\1" MAJOR_MINOR "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BOINC/boinc
    REF "client_release/${MAJOR_MINOR}/${VERSION}"
    SHA512 a53506bc3e92c813e7cc1a9be8741822aabc843f6ca824e35a0cd48cec34d0965d51bf97dfea2ec4898c5c36887c8bbdc4919a46a093ad2ac43b081eca3ad882
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        NO_ADDITIONAL_PATHS
        OPTIONS
            ${OPTIONS}
            --disable-server
            --disable-client
            --disable-manager
    )

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.h DESTINATION ${SOURCE_PATH}/config-h-Release)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.h DESTINATION ${SOURCE_PATH}/config-h-Debug)
    endif()
endif()

set(build_options "")
if(VCPKG_TARGET_IS_MINGW)
    list(APPEND build_options "-DHAVE_STRCASECMP=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${build_options}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
file(READ "${CURRENT_PACKAGES_DIR}/share/boinc/boinc-config.cmake" BOINC_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/boinc/boinc-config.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(OpenSSL)
${BOINC_CONFIG}
")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING.LESSER" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME license)
