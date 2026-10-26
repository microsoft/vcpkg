include(CMakeFindDependencyMacro)

set(brazier_known_components logger core orm)

foreach(_comp IN LISTS brazier_FIND_COMPONENTS)
    if(NOT _comp IN_LIST brazier_known_components)
        set(brazier_FOUND FALSE)
        set(brazier_NOT_FOUND_MESSAGE
            "Unknown component '${_comp}'. Known: ${brazier_known_components}")
        return()
    endif()
endforeach()

if(NOT brazier_FIND_COMPONENTS OR "logger" IN_LIST brazier_FIND_COMPONENTS)
    find_dependency(brazier-logger CONFIG)
    if(TARGET brazier::logger)
        set(brazier_logger_FOUND TRUE)
    else()
        set(brazier_logger_FOUND FALSE)
    endif()
endif()

if(NOT brazier_FIND_COMPONENTS OR "core" IN_LIST brazier_FIND_COMPONENTS)
    find_dependency(brazier-core CONFIG)
    if(TARGET brazier::core)
        set(brazier_core_FOUND TRUE)
    else()
        set(brazier_core_FOUND FALSE)
    endif()
endif()

if("orm" IN_LIST brazier_FIND_COMPONENTS)
    find_dependency(brazier-orm CONFIG)
    if(TARGET brazier::orm)
        set(brazier_orm_FOUND TRUE)
    else()
        set(brazier_orm_FOUND FALSE)
    endif()
endif()

if(NOT TARGET brazier::brazier)
    add_library(brazier::brazier INTERFACE IMPORTED GLOBAL)

    set(_brazier_libs)
    if(TARGET brazier::logger)
        list(APPEND _brazier_libs brazier::logger)
    endif()
    if(TARGET brazier::core)
        list(APPEND _brazier_libs brazier::core)
    endif()
    if(TARGET brazier::orm)
        list(APPEND _brazier_libs brazier::orm)
    endif()

    set_target_properties(brazier::brazier PROPERTIES
        INTERFACE_LINK_LIBRARIES "${_brazier_libs}"
    )
endif()

check_required_components(brazier)