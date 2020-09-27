_find_package(${ARGS})

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    find_package(Intl REQUIRED)
    if(TARGET exiv2lib)
        set_property(TARGET exiv2lib APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${Intl_LIBRARIES})
        set_property(TARGET exiv2lib APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${Intl_INCLUDE_DIRS})
    endif()
endif()
