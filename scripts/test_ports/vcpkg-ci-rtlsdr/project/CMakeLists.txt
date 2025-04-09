cmake_minimum_required(VERSION 3.10)
project(rtlsdr-test C)

find_package(PkgConfig REQUIRED)

block()
    find_package(rtlsdr CONFIG REQUIRED)

    add_executable(rtlsdr_cmake main.c)
    target_link_libraries(rtlsdr_cmake $<IF:$<TARGET_EXISTS:rtlsdr::rtlsdr>,rtlsdr::rtlsdr,rtlsdr::rtlsdr_static>)
endblock()

block()
    pkg_check_modules(librtlsdr IMPORTED_TARGET REQUIRED librtlsdr)

    add_executable(rtlsdr_pkgconfig main.c)
    target_link_libraries(rtlsdr_pkgconfig PkgConfig::librtlsdr)
endblock()
