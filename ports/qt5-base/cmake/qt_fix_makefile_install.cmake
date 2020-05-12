#Could probably be a vcpkg_fix_makefile_install for other ports?
function(qt_fix_makefile_install BUILD_DIR)
    #Fix the installation location
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
    
    if(WIN32)
        string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 2 -1 INSTALLED_DIR_WITHOUT_DRIVE)
        string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 2 -1 PACKAGES_DIR_WITHOUT_DRIVE)
    else()
        set(INSTALLED_DIR_WITHOUT_DRIVE ${NATIVE_INSTALLED_DIR})
        set(PACKAGES_DIR_WITHOUT_DRIVE ${NATIVE_PACKAGES_DIR})
    endif()

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
    
    file(GLOB_RECURSE MAKEFILES "${BUILD_DIR}/*Makefile*")

    foreach(MAKEFILE ${MAKEFILES})
        file(READ "${MAKEFILE}" _contents)
        #Set the correct install directory to packages
        string(REPLACE "(INSTALL_ROOT)${INSTALLED_DIR_WITHOUT_DRIVE}" "(INSTALL_ROOT)${PACKAGES_DIR_WITHOUT_DRIVE}" _contents "${_contents}")
        file(WRITE "${MAKEFILE}" "${_contents}")
    endforeach()
endfunction()