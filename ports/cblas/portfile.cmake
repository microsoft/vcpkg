SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# See explanation in ports/blas/portfile.cmake for which blas implementation is chosen.
set(requires blas)
    
configure_file("${CMAKE_CURRENT_LIST_DIR}/cblas.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cblas.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/cblas.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cblas.pc" @ONLY)
endif()
