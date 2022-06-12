if(Z_VCPKG_LIBTOOL_GUARD)
    return()
endif()
set(Z_VCPKG_LIBTOOL_GUARD ON CACHE INTERNAL "guard variable")

cmake_path(SET z_vcpkg_libtool_dir NORMALIZE "${CMAKE_CURRENT_LIST_DIR}/../..")
set(LIBTOOL_EXECUTABLE "${z_vcpkg_libtool_dir}/tools/@PORT@/bin/libtool" CACHE PATH "The libtool executable")
set(LIBTOOLIZE_EXECUTABLE "${z_vcpkg_libtool_dir}/tools/@PORT@/bin/libtoolize" CACHE PATH "The libtoolize executable")
vcpkg_host_path_list(PREPEND ENV{PATH} "${z_vcpkg_libtool_dir}/tools/@PORT@/bin")
vcpkg_host_path_list(PREPEND ENV{ACLOCAL_PATH} "${z_vcpkg_libtool_dir}/share/@PORT@/aclocal")
unset(z_vcpkg_libtool_dir)

include("${CMAKE_CURRENT_LIST_DIR}/x_vcpkg_update_libtool.cmake")
