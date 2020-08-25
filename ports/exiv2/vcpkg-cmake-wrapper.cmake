_find_package(${ARGS})

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    find_package(Iconv REQUIRED)
    find_package(Intl REQUIRED)
    if(TARGET exiv2lib)
        set_property(TARGET exiv2lib APPEND PROPERTY INTERFACE_LINK_LIBRARIES 
            Iconv::Iconv 
            )
        target_link_libraries(exiv2lib INTERFACE ${Intl_LIBRARIES})
    endif()
endif()
