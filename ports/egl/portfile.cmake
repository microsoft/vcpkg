set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/egl/vcpkg-cmake-wrapper.cmake" @ONLY)

if(VCPKG_TARGET_IS_WINDOWS)
    set(KHRONOS_STATIC "")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(KHRONOS_STATIC "-DKHRONOS_STATIC")
    endif()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/egl.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/egl.pc" @ONLY)
    if (NOT VCPKG_BUILD_TYPE)
        configure_file("${CMAKE_CURRENT_LIST_DIR}/egl.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/egl.pc" @ONLY)
    endif()
endif()
