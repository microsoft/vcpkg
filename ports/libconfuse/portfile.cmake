include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinh/libconfuse
    REF 2f7d120e170351cf424845ed27a532cce443247d
    SHA512 f80f4e2c93d9e2640758c0876147e26874e4627bd133df55e429b9d703d8ab4917c49eec3ca37a4e484f569f01ea1ebbf4867eb97097917dbfb9e0761ddb8714
    HEAD_REF master
    PATCHES
        fix-uwp-build.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR ${FLEX} DIRECTORY)
vcpkg_add_to_path(${FLEX_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/confuse.h
        "ifdef CONFUSE_STATIC_LIB"
        "if 1 // ifdef CONFUSE_STATIC_LIB"
    )
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME unofficial-${PORT})
