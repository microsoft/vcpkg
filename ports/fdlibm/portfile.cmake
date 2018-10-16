include(vcpkg_common_functions)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://android.googlesource.com/platform/external/fdlibm
    REF 59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac
    SHA512 08c16ff7cc6f24d962090bf5ab192d3c8ab33d9f60390ca510898c918cefa1b19572ad6bbf49c327bb09d8a9ab52d8341ec14c44abe169d2d319523567f1300f
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libm5.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG 
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/NOTICE ${CURRENT_PACKAGES_DIR}/share/fdlibm/copyright COPYONLY)
