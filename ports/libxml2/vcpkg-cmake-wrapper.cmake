_find_package(${ARGS})
if(LibXml2_FOUND)
    find_package(LibLZMA)
    find_package(unofficial-iconv REQUIRED)
    set_property(TARGET LibXml2::LibXml2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES 
        unofficial::iconv::libcharset 
        unofficial::iconv::libiconv
        ${LIBLZMA_LIBRARIES})
    list(APPEND LIBXML2_LIBRARIES
        unofficial::iconv::libcharset 
        unofficial::iconv::libiconv
        ${LIBLZMA_LIBRARIES})
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        list(APPEND LIBXML2_LIBRARIES ws2_32)
    endif()
endif()
