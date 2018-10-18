include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("parson only supports static linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kgabis/parson
    REF 0a1896939faff5f69e179637fc49f678ff0128ba
    SHA512 cb982ce7dbbe0b5a4d08a28a459e9dce5347f90d75b0a37c56698f5b79ad37aa0bd22fe6b6d5c8a6fda2dd83b072605486581360b8ed3591012ebaa1e1518fc6
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/parson.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-parson TARGET_PATH share/unofficial-parson)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/parson RENAME copyright)

vcpkg_copy_pdbs()
