# Create helper file for iconv usage requirement
find_package(Iconv REQUIRED)
set(poppler_iconv [[
Name: poppler-vcpkg-iconv
Description: iconv linking requirements for poppler
Version: 0
Libs:]])
string(TOLOWER "${Iconv_LIBRARIES}" iconv_libraries)
if(iconv_libraries MATCHES "iconv")
    string(APPEND poppler_iconv " -liconv")
endif()
if(iconv_libraries MATCHES "charset")
    string(APPEND poppler_iconv " -lcharset")
endif()
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/poppler-vcpkg-iconv.pc" "${poppler_iconv}")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/poppler-vcpkg-iconv.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
