project(TBB_static)

set(DUMMY ${PROJECT_SOURCE_DIR}/dummy.cpp)
file(WRITE ${DUMMY} "#include <stdio.h>")

if(WIN32)
    set(TBB_PROJECT_DIR ${PROJECT_SOURCE_DIR}/../build/vs2013/${BUILD_ARCH})

    foreach(CURRENT_LIB tbb tbbmalloc tbbmalloc_proxy)
        add_library(${CURRENT_LIB}${SUFFIX} STATIC ${DUMMY})

        # Link it with *.obj
        set_property(
            TARGET ${CURRENT_LIB}${SUFFIX}
            APPEND_STRING
            PROPERTY
                STATIC_LIBRARY_FLAGS
                ${TBB_PROJECT_DIR}/${CURRENT_LIB}/${CONFIGURATION}/*${CMAKE_CXX_OUTPUT_EXTENSION})

        install(TARGETS ${CURRENT_LIB}${SUFFIX} DESTINATION lib)
    endforeach()
else()
    if (CMAKE_BUILD_TYPE STREQUAL Debug)
        set(TBB_PROJECT_DIR ${PROJECT_SOURCE_DIR}/../build/*_debug)
    else()
        set(TBB_PROJECT_DIR ${PROJECT_SOURCE_DIR}/../build/*_release)
    endif()

    add_library(tbb${SUFFIX} STATIC ${DUMMY})

    # Link it with *.o
    set_property(
        TARGET tbb${SUFFIX}
        APPEND_STRING
        PROPERTY
            STATIC_LIBRARY_FLAGS
            ${TBB_PROJECT_DIR}/*${CMAKE_CXX_OUTPUT_EXTENSION})

    install(TARGETS tbb${SUFFIX} DESTINATION lib)
endif()
