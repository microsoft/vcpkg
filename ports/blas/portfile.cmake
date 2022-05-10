SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(READ "${CURRENT_PORT_DIR}/vcpkg.json" manifest_contents)
string(JSON ver_str GET "${manifest_contents}" version-string)

if(ver_str STREQUAL "default")
    # OpenBLAS
    if(VCPKG_TARGET_IS_OSX)
        set(BLA_VENDOR Apple)
        set(requires "")
        set(libs "-framework Accelerate")
        set(cflags "-framework Accelerate")
    else()
        set(BLA_VENDOR OpenBLAS)
        set(requires openblas)
    endif()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/blas.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc" @ONLY)
    if(NOT VCPKG_BUILD_TYPE)
        configure_file("${CMAKE_CURRENT_LIST_DIR}/blas.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc" @ONLY)
    endif()

    # For possible overlays:

    #NETLIB reference implementation (contained in lapack-reference)
    #set(BLA_VENDOR Generic)

    # Intel MKL
    #if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    #    set(BLA_VENDOR Intel10_64lp)
    #elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    #    set(BLA_VENDOR Intel10_32)
    #else()
    #    message(FATAL_ERROR "Unsupported target architecture for Intel MKL!")
    #endif()

    # Apple Accelerate Framework
    # set(BLA_VENDOR Apple)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(BLA_STATIC ON)
    else()
        set(BLA_STATIC OFF)
    endif()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/blas/vcpkg-cmake-wrapper.cmake" @ONLY)
endif()