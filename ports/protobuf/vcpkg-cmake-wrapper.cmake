if(NOT "CONFIG" IN_LIST ARGS AND NOT "NO_MODULE" IN_LIST ARGS)
    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        set(Protobuf_USE_STATIC_LIBS ON)
    else()
        set(Protobuf_USE_STATIC_LIBS OFF)
    endif()
endif()

_find_package(${ARGS})
