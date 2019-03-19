_find_package(${ARGS})
if(LibXml2_FOUND)
    find_package(LibLZMA)
    find_package(ZLIB)
    find_package(unofficial-iconv REQUIRED)
    set_property(TARGET LibXml2::LibXml2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES 
        unofficial::iconv::libcharset 
        unofficial::iconv::libiconv)
    target_link_libraries(LibXml2::LibXml2 INTERFACE ${LIBLZMA_LIBRARIES} ${ZLIB_LIBRARIES}) # for VTK
    list(APPEND LIBXML2_LIBRARIES
        unofficial::iconv::libcharset 
        unofficial::iconv::libiconv
        ${LIBLZMA_LIBRARIES} ${ZLIB_LIBRARIES})
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        list(APPEND LIBXML2_LIBRARIES ws2_32)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        list(APPEND LIBXML2_LIBRARIES m)
    endif()
endif()
