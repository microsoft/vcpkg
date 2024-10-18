_find_package(${ARGS})

if(Intl_FOUND AND Intl_LIBRARIES)
    include(SelectLibraryConfigurations)
    find_library(Intl_LIBRARY_DEBUG NAMES intl libintl intl-8 NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH)
    find_library(Intl_LIBRARY_RELEASE NAMES intl libintl intl-8 NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH)
    unset(Intl_LIBRARIES)
    unset(Intl_LIBRARIES CACHE)
    select_library_configurations(Intl)
    find_package(Iconv) # Since CMake 3.11
    if(Iconv_FOUND AND NOT Iconv_IS_BUILT_IN)
        list(APPEND Intl_LIBRARIES ${Iconv_LIBRARIES})
        if(TARGET Intl::Intl) # Since CMake 3.20
            set_property(TARGET Intl::Intl APPEND PROPERTY INTERFACE_LINK_LIBRARIES $<LINK_ONLY:Iconv::Iconv>)
        endif()
    endif()
    if(APPLE)
        list(APPEND Intl_LIBRARIES "-framework CoreFoundation")
        if(TARGET Intl::Intl) # Since CMake 3.20
            set_property(TARGET Intl::Intl APPEND PROPERTY INTERFACE_LINK_LIBRARIES "$<LINK_ONLY:-framework CoreFoundation>")
        endif()
    endif()
endif()
