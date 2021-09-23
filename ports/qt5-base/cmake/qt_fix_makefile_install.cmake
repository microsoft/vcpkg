#Could probably be a vcpkg_fix_makefile_install for other ports?
function(qt_fix_makefile_install BUILD_DIR)
    #Fix the installation location
    set(MSYSHACK "")
    if(CMAKE_HOST_WIN32)
        if(VCPKG_TARGET_IS_MINGW)
            set(NATIVE_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}")
            set(NATIVE_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}")
            set(MSYSHACK ":@msyshack@%=%")
        else()
            file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
            file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
        endif()
        string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 0 2 INSTALLED_DRIVE)
        string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 0 2 PACKAGES_DRIVE)
        string(SUBSTRING "${NATIVE_INSTALLED_DIR}" 2 -1 INSTALLED_DIR_WITHOUT_DRIVE)
        string(SUBSTRING "${NATIVE_PACKAGES_DIR}" 2 -1 PACKAGES_DIR_WITHOUT_DRIVE)
    else()
        set(INSTALLED_DRIVE "")
        set(PACKAGES_DRIVE "")
        set(INSTALLED_DIR_WITHOUT_DRIVE "${CURRENT_INSTALLED_DIR}")
        set(PACKAGES_DIR_WITHOUT_DRIVE "${CURRENT_PACKAGES_DIR}")
    endif()

    file(GLOB_RECURSE MAKEFILES "${BUILD_DIR}/*Makefile*")

    foreach(MAKEFILE IN LISTS MAKEFILES)
        #Set the correct install directory to packages
        vcpkg_replace_string("${MAKEFILE}"
            "${INSTALLED_DRIVE}$(INSTALL_ROOT${MSYSHACK})${INSTALLED_DIR_WITHOUT_DRIVE}"
            "${PACKAGES_DRIVE}$(INSTALL_ROOT${MSYSHACK})${PACKAGES_DIR_WITHOUT_DRIVE}"
        )
    endforeach()
endfunction()