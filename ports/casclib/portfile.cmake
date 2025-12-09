vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/CascLib
    REF 1623348517352ff0d6364d47533c0d7f118b46e1
    SHA512 1b6dd77a399ff21a278d1ac68efa1417f2a9472b241401d3f6cb8f01ea702b32b4296012bb71ae62a932f9b0fa2b6d3035befe6f3ba0d567e85ac747c503b07c
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CASC_BUILD_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CASC_BUILD_STATIC_LIB)

set(CASC_UNICODE OFF)

if(VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "This version of CascLib is built in ASCII mode. To switch to UNICODE version, create an overlay port of this with CASC_UNICODE set to ON.")
    message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
    message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
        -DCASC_BUILD_SHARED_LIB=${CASC_BUILD_SHARED_LIB}
        -DCASC_BUILD_STATIC_LIB=${CASC_BUILD_STATIC_LIB}
        -DCASC_UNICODE=${CASC_UNICODE}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CascLib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
