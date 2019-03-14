include("${CMAKE_CURRENT_LIST_DIR}/unofficial-iconv-targets.cmake")

set_target_properties(unofficial::iconv::libcharset PROPERTIES IMPORTED_GLOBAL TRUE)
set_target_properties(unofficial::iconv::libiconv PROPERTIES IMPORTED_GLOBAL TRUE)

if(APPLE)
    set_property(TARGET unofficial::iconv::libcharset PROPERTY INTERFACE_LINK_LIBRARIES "charset;unofficial::iconv::libiconv")
    set_property(TARGET unofficial::iconv::libiconv PROPERTY INTERFACE_LINK_LIBRARIES "iconv")
endif()