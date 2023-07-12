if(NOT TARGET vk-bootstrap::vk-bootstrap)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    add_library(vk-bootstrap::vk-bootstrap UNKNOWN IMPORTED)
    set_target_properties(vk-bootstrap::vk-bootstrap PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include")

    find_library(Z_VCPKG_VKBOOTSTRAP_LIBRARY_RELEASE NAMES vk-bootstrap PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH REQUIRED)
    set_property(TARGET vk-bootstrap::vk-bootstrap APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
    set_target_properties(vk-bootstrap::vk-bootstrap PROPERTIES IMPORTED_LOCATION_RELEASE "${Z_VCPKG_VKBOOTSTRAP_LIBRARY_RELEASE}")

    find_library(Z_VCPKG_VKBOOTSTRAP_LIBRARY_DEBUG NAMES vk-bootstrap PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
    if(Z_VCPKG_VKBOOTSTRAP_LIBRARY_DEBUG)
        set_property(TARGET vk-bootstrap::vk-bootstrap APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(vk-bootstrap::vk-bootstrap PROPERTIES IMPORTED_LOCATION_DEBUG "${Z_VCPKG_VKBOOTSTRAP_LIBRARY_DEBUG}")
    endif()

    if(CMAKE_DL_LIBS)
        set_target_properties(vk-bootstrap::vk-bootstrap PROPERTIES INTERFACE_LINK_LIBRARIES ${CMAKE_DL_LIBS})
    endif()

    unset(_IMPORT_PREFIX)
endif()
