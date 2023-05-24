include_guard(GLOBAL)
function(z_vcpkg_qmake_fix_makefiles BUILD_DIR)
    #Fix the installation location
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
    
    if(WIN32)
        string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 2 -1 INSTALLED_DIR_WITHOUT_DRIVE)
        string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 2 -1 PACKAGES_DIR_WITHOUT_DRIVE)
        string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 0 2 INSTALLED_DRIVE)
        string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 0 2 PACKAGES_DRIVE)
    else()
        set(INSTALLED_DRIVE "")
        set(PACKAGES_DRIVE "")
        set(INSTALLED_DIR_WITHOUT_DRIVE "${NATIVE_INSTALLED_DIR}")
        set(PACKAGES_DIR_WITHOUT_DRIVE "${NATIVE_PACKAGES_DIR}")
    endif()

    file(GLOB_RECURSE MAKEFILES "${BUILD_DIR}/**Makefile**")

    foreach(MAKEFILE ${MAKEFILES})
        #Set the correct install directory to packages
        vcpkg_replace_string("${MAKEFILE}"
            "${INSTALLED_DRIVE}$(INSTALL_ROOT)${INSTALLED_DIR_WITHOUT_DRIVE}"
            "${PACKAGES_DRIVE}$(INSTALL_ROOT)${PACKAGES_DIR_WITHOUT_DRIVE}")
    endforeach()

endfunction()