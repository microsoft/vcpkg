include(SelectLibraryConfigurations)

_find_package(RdKafka CONFIG)

if(RdKafka_FOUND)
    if(TARGET RdKafka::rdkafka)
        set(TARGETNAME RdKafka::rdkafka)
    else(TARGET RdKafka::rdkafka++)
        set(TARGETNAME RdKafka::rdkafka++)
    endif()

    if(TARGET ${TARGETNAME} AND NOT DEFINED RdKafka_INCLUDE_DIRS)
        get_target_property(RdKafka_INCLUDE_DIRS ${TARGETNAME} INTERFACE_INCLUDE_DIRECTORIES)
        set(RdKafka_INCLUDE_DIR ${RdKafka_INCLUDE_DIRS})
        
        get_target_property(_RdKafka_DEFS ${TARGETNAME} INTERFACE_COMPILE_DEFINITIONS)
        
        if("${_RdKafka_DEFS}" MATCHES "RdKafka_STATIC")
            get_target_property(RdKafka_LIBRARY_DEBUG ${TARGETNAME} IMPORTED_IMPLIB_DEBUG)
            get_target_property(RdKafka_LIBRARY_RELEASE ${TARGETNAME} IMPORTED_IMPLIB_RELEASE)       
        else()
            get_target_property(RdKafka_LIBRARY_DEBUG ${TARGETNAME} IMPORTED_LOCATION_DEBUG)
            get_target_property(RdKafka_LIBRARY_RELEASE ${TARGETNAME} IMPORTED_LOCATION_RELEASE)
        endif()
        
        get_target_property(_RdKafka_LINK_INTERFACE ${TARGETNAME} IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE) # same for debug and release
        
        list(APPEND RdKafka_LIBRARIES ${_RdKafka_LINK_INTERFACE})
        list(APPEND RdKafka_LIBRARY ${_RdKafka_LINK_INTERFACE})
        
        select_library_configurations(RdKafka)
        
        if("${_RdKafka_DEFS}" MATCHES "RdKafka_STATIC")
            set(RdKafka_STATIC_LIBRARIES ${RdKafka_LIBRARIES})
        else()
            set(RdKafka_SHARED_LIBRARIES ${RdKafka_LIBRARIES})
        endif()
        
        unset(_RdKafka_DEFS)
        unset(_RdKafka_LINK_INTERFACE)
    endif() 
endif()