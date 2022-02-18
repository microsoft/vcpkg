_find_package(${ARGS})

if(WIN32)
    list(APPEND LibUV_LIBRARIES iphlpapi psapi shell32 userenv ws2_32)
    if(TARGET LibUV::LibUV)
        set_property(TARGET LibUV::LibUV APPEND PROPERTY INTERFACE_LINK_LIBRARIES iphlpapi psapi shell32 userenv ws2_32)
    endif()
endif()
include(CMakeFindDependencyMacro)
find_dependency(Threads)
list(APPEND LibUV_LIBRARIES Threads::Threads)
if(TARGET LibUV::LibUV)
    set_property(TARGET LibUV::LibUV APPEND PROPERTY INTERFACE_LINK_LIBRARIES Threads::Threads)
endif()


