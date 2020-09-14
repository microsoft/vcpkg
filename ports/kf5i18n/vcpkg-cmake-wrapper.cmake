_find_package(${ARGS})

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    find_package(unofficial-iconv CONFIG REQUIRED)
    find_package(unofficial-gettext CONFIG REQUIRED)
    if(TARGET KF5Ii8N)
        set_property(TARGET KF5I18N APPEND PROPERTY INTERFACE_LINK_LIBRARIES 
            unofficial::iconv::libiconv 
            unofficial::gettext::libintl)
    endif()
endif()
