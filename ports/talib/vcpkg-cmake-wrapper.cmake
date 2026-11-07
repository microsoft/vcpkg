message(WARNING "find_package(talib) and talib::talib are deprecated. Use:\n"
    "  find_package(ta-lib CONFIG REQUIRED)\n"
    "  target_link_libraries(main PRIVATE ta-lib::ta-lib)")

set(z_vcpkg_talib_args "")
foreach(z_vcpkg_talib_arg IN ITEMS REQUIRED QUIET)
    list(FIND ARGS "${z_vcpkg_talib_arg}" z_vcpkg_talib_index)
    if(NOT z_vcpkg_talib_index EQUAL -1)
        list(APPEND z_vcpkg_talib_args ${z_vcpkg_talib_arg})
    endif()
endforeach()
find_package(ta-lib CONFIG ${z_vcpkg_talib_args})
unset(z_vcpkg_talib_arg)
unset(z_vcpkg_talib_index)
unset(z_vcpkg_talib_args)

if(ta-lib_FOUND AND NOT TARGET talib::talib)
    add_library(talib::talib INTERFACE IMPORTED)
    set_target_properties(talib::talib PROPERTIES INTERFACE_LINK_LIBRARIES ta-lib::ta-lib)
endif()
set(talib_FOUND "${ta-lib_FOUND}")
set(TALIB_FOUND "${ta-lib_FOUND}")
