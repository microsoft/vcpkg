include(SelectLibraryConfigurations)

list(REMOVE_ITEM ARGS "NO_MODULE")
list(REMOVE_ITEM ARGS "CONFIG")
list(REMOVE_ITEM ARGS "MODULE")

_find_package(${ARGS} CONFIG)

if(RdKafka_FOUND)
    if(TARGET RdKafka::rdkafka)
        set(TARGET_NAME RdKafka::rdkafka)
    else(TARGET RdKafka::rdkafka++)
        set(TARGET_NAME RdKafka::rdkafka++)
    endif()

    if(TARGET ${TARGET_NAME} AND NOT DEFINED RdKafka_INCLUDE_DIRS)
        get_target_property(_RdKafka_INCLUDE_DIRS ${TARGET_NAME} INTERFACE_INCLUDE_DIRECTORIES)
        get_target_property(_RdKafka_LINK_LIBRARIES ${TARGET_NAME} INTERFACE_LINK_LIBRARIES)

        if (CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
            get_target_property(_RdKafka_LIBRARY_DEBUG ${TARGET_NAME} IMPORTED_IMPLIB_DEBUG)
            get_target_property(_RdKafka_LIBRARY_RELEASE ${TARGET_NAME} IMPORTED_IMPLIB_RELEASE)
        endif()

        if(NOT _RdKafka_LIBRARY_DEBUG AND NOT _RdKafka_LIBRARY_RELEASE)
            get_target_property(_RdKafka_LIBRARY_DEBUG ${TARGET_NAME} IMPORTED_LOCATION_DEBUG)
            get_target_property(_RdKafka_LIBRARY_RELEASE ${TARGET_NAME} IMPORTED_LOCATION_RELEASE)
        endif()

        set(RdKafka_INCLUDE_DIR "${_RdKafka_INCLUDE_DIRS}")
        set(RdKafka_LIBRARY_DEBUG "${_RdKafka_LIBRARY_DEBUG}")
        set(RdKafka_LIBRARY_RELEASE "${_RdKafka_LIBRARY_RELEASE}")

        select_library_configurations(RdKafka)

        list(APPEND RdKafka_LIBRARIES ${_RdKafka_LINK_LIBRARIES})
        list(APPEND RdKafka_LIBRARY ${_RdKafka_LINK_LIBRARIES})

        unset(_RdKafka_INCLUDE_DIRS)
        unset(_RdKafka_LINK_LIBRARIES)
        unset(_RdKafka_LIBRARY_DEBUG)
        unset(_RdKafka_LIBRARY_DEBUG)
        unset(TARGET_NAME)
    endif() 
endif()