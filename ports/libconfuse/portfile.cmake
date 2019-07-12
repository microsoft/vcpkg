include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinh/libconfuse
    REF 398123ffbf5baea47b946c4a72fc1e56957749a9
    SHA512 46a59829b8bea4fac4d2940fbf357a25e491737bbf088813e918f8ac4b1948bb1a2317f1ae2dcc6cc06ce0002314189cfeb99da7a43cbe1b47e7b91fe317cd2d
    HEAD_REF master
    PATCHES
        static-lib.patch
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
