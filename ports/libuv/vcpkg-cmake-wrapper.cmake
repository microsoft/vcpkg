_find_package(${ARGS})

if(WIN32)
    list(APPEND LibUV_LIBRARIES iphlpapi psapi shell32 userenv ws2_32)
    if(TARGET LibUV::LibUV)
        target_link_libraries(LibUV::LibUV INTERFACE iphlpapi psapi shell32 userenv ws2_32)
    endif()
endif()
include(CMakeFindDependencyMacro)
find_dependency(Threads)
list(APPEND LibUV_LIBRARIES Threads::Threads)
if(TARGET LibUV::LibUV)
    target_link_libraries(LibUV::LibUV INTERFACE Threads::Threads)
endif()


