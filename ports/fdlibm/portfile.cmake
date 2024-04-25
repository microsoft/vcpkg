vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://android.googlesource.com/platform/external/fdlibm
    REF 59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libm5.def" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG 
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
configure_file("${SOURCE_PATH}/NOTICE" "${CURRENT_PACKAGES_DIR}/share/fdlibm/copyright" COPYONLY)
 
