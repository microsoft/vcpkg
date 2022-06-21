vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO woollybah/gppanel
    REF f58a9028f7c9a8e9b4324ff2165951f558365f90
    SHA512 4ec5fbef4c487d351c60f48b0c0e41c5d077989ab96f827b9fd5ef01c167d50f39a313bd82db1b5df19d14025983e83db4d19cc4048c1c50fc8ef9128de15575
    HEAD_REF master
    PATCHES 
        00001-fix-build.patch
        use-complex-header.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/gpPanel)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/gppanel/copyright COPYONLY)
