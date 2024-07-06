vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphql/libgraphqlparser
    REF v0.7.0
    SHA512 973292b164d0d2cfe453a2f01559dbdb1b9d22b6304f6a3aabf71e2c0a3e24ab69dfd72a086764ad5befecf0005620f8e86f552dacc324f9615a05f31de7cede
    HEAD_REF master
    PATCHES
        win-cmake.patch
        static-compile-fix.patch
        remove-invalid-bison-directive.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        DISABLE_PARALLEL_CONFIGURE
    )
elseif(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_find_acquire_program(PYTHON2)
    vcpkg_find_acquire_program(FLEX)
    vcpkg_find_acquire_program(BISON)

    get_filename_component(VCPKG_DOWNLOADS_PYTHON2_DIR "${PYTHON2}" DIRECTORY)
    get_filename_component(VCPKG_DOWNLOADS_FLEX_DIR "${FLEX}" DIRECTORY)
    get_filename_component(VCPKG_DOWNLOADS_BISON_DIR "${BISON}" DIRECTORY)

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        DISABLE_PARALLEL_CONFIGURE
        OPTIONS
            -DVCPKG_DOWNLOADS_PYTHON2_DIR=${VCPKG_DOWNLOADS_PYTHON2_DIR}
            -DVCPKG_DOWNLOADS_FLEX_DIR=${VCPKG_DOWNLOADS_FLEX_DIR}
            -DVCPKG_DOWNLOADS_BISON_DIR=${VCPKG_DOWNLOADS_BISON_DIR}
    )
endif()

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/graphqlparser/parser.tab.hpp" "${SOURCE_PATH}" "" IGNORE_UNCHANGED)

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/graphqlparser/copyright" COPYONLY)

