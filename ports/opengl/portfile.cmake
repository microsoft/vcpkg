set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/opengl.pc"
                 "${CMAKE_CURRENT_LIST_DIR}/glu.pc"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig"
    )
    if(NOT VCPKG_BUILD_TYPE)
        file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/opengl.pc"
                    "${CMAKE_CURRENT_LIST_DIR}/glu.pc"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
        )
    endif()
    vcpkg_fixup_pkgconfig()
endif()
