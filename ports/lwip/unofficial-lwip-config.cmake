if(NOT DEFINED LWIP_INCLUDE_DIRS)
    message(FATAL_ERROR
        "Set LWIP_INCLUDE_DIRS to the directories containing lwipopts.h and "
        "the platform port headers before calling find_package(unofficial-lwip)."
    )
endif()

get_filename_component(LWIP_DIR "${CMAKE_CURRENT_LIST_DIR}/../lwip" ABSOLUTE)
set(LWIP_CONTRIB_DIR "${LWIP_DIR}/contrib")
get_filename_component(_LWIP_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
list(PREPEND LWIP_INCLUDE_DIRS "${_LWIP_PREFIX}/include")
unset(_LWIP_PREFIX)

include("${LWIP_DIR}/src/Filelists.cmake")

# The upstream targets use private include directories because their examples
# add the same directories directly to each application. Expose them publicly
# for conventional find_package()/target_link_libraries() consumption.
target_include_directories(lwipcore PUBLIC ${LWIP_INCLUDE_DIRS})
target_include_directories(lwipallapps PUBLIC ${LWIP_INCLUDE_DIRS})
target_link_libraries(lwipallapps PUBLIC lwipcore)

if(NOT TARGET unofficial::lwip::core)
    add_library(unofficial::lwip::core ALIAS lwipcore)
endif()

if(NOT TARGET unofficial::lwip::apps)
    add_library(unofficial::lwip::apps ALIAS lwipallapps)
endif()
