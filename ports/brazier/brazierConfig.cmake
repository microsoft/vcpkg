@PACKAGE_INIT@

include(CMakeFindDependencyMacro)

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../brazier-logger/brazier-loggerConfig.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/../brazier-logger/brazier-loggerConfig.cmake")
endif()

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../brazier-core/brazier-coreConfig.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/../brazier-core/brazier-coreConfig.cmake")
endif()

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../brazier-orm/brazier-ormConfig.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/../brazier-orm/brazier-ormConfig.cmake")
endif()

if(NOT TARGET brazier::brazier)
    add_library(brazier::brazier INTERFACE IMPORTED)
    
    if(TARGET brazier::logger)
        set_property(TARGET brazier::brazier APPEND PROPERTY INTERFACE_LINK_LIBRARIES brazier::logger)
    endif()
    if(TARGET brazier::core)
        set_property(TARGET brazier::brazier APPEND PROPERTY INTERFACE_LINK_LIBRARIES brazier::core)
    endif()
    if(TARGET brazier::orm)
        set_property(TARGET brazier::brazier APPEND PROPERTY INTERFACE_LINK_LIBRARIES brazier::orm)
    endif()
endif()

check_required_components(brazier)