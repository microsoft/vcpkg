_find_package(${ARGS})

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    find_package(Iconv REQUIRED)
    if(@EXIV2_ENABLE_NLS@)
        find_package(Intl REQUIRED)
    endif()
    if(TARGET exiv2lib)
        set_property(TARGET exiv2lib APPEND PROPERTY INTERFACE_LINK_LIBRARIES 
            Iconv::Iconv 
            )
        if(@EXIV2_ENABLE_NLS@)
            target_link_libraries(exiv2lib INTERFACE ${Intl_LIBRARIES})
        endif()
    endif()
endif()
