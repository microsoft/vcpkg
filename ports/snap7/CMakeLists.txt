# CMakeList.txt : CMake project for Snap7, include source and define
# project specific logic here.
cmake_minimum_required (VERSION 3.8)

project(snap7
        VERSION 1.4.2
        LANGUAGES CXX)

# Add source to this project's executable.
add_library(${PROJECT_NAME} SHARED "core/s7_client.cpp"
                                   "core/s7_client.h"
                                   "core/s7_firmware.h"
                                   "core/s7_isotcp.cpp"
                                   "core/s7_isotcp.h"
                                   "core/s7_micro_client.cpp"
                                   "core/s7_micro_client.h"
                                   "core/s7_partner.cpp"
                                   "core/s7_partner.h"
                                   "core/s7_peer.cpp"
                                   "core/s7_peer.h"
                                   "core/s7_server.cpp"
                                   "core/s7_server.h"
                                   "core/s7_text.cpp"
                                   "core/s7_text.h"
                                   "core/s7_types.h"
                                   "lib/snap7_libmain.cpp"
                                   "lib/snap7_libmain.h"
                                   "sys/snap_msgsock.cpp"
                                   "sys/snap_msgsock.h"
                                   "sys/snap_platform.h"
                                   "sys/snap_sysutils.cpp"
                                   "sys/snap_sysutils.h"
                                   "sys/snap_tcpsrvr.cpp"
                                   "sys/snap_tcpsrvr.h"
                                   "sys/snap_threads.cpp"
                                   "sys/snap_threads.h"
                                   "sys/sol_threads.h"
                                   "sys/unix_threads.h"
                                   "sys/win_threads.h"
                                   )

if(MSVC)
  target_link_libraries(${PROJECT_NAME} wsock32 ws2_32)
  target_link_libraries(${PROJECT_NAME} winmm.lib)
endif()

add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/core> $<INSTALL_INTERFACE:include>)
target_include_directories(${PROJECT_NAME} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lib> $<INSTALL_INTERFACE:include>)
target_include_directories(${PROJECT_NAME} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sys> $<INSTALL_INTERFACE:include>)

install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME})

install(
    EXPORT ${PROJECT_NAME} 
    FILE ${PROJECT_NAME}-config.cmake
    DESTINATION "share/${PROJECT_NAME}"
    NAMESPACE ${PROJECT_NAME}::
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY "core/" DESTINATION include/${PROJECT_NAME} FILES_MATCHING PATTERN "*.h")
  install(DIRECTORY "lib/" DESTINATION include/${PROJECT_NAME} FILES_MATCHING PATTERN "*.h")
  install(DIRECTORY "sys/" DESTINATION include/${PROJECT_NAME} FILES_MATCHING PATTERN "*.h")
endif()
