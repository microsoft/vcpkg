cmake_minimum_required(VERSION 3.5)
project(soundtouch CXX)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCH_SUFFIX _x64)
else()
    set(ARCH_SUFFIX)
endif()

if(BUILD_SHARED_LIBS)
    set(TYPE_SUFFIX Dll)
else()
    set(TYPE_SUFFIX $<$<Config:Debug>:D>)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/include/soundtouch_config.h.in" ${CMAKE_CURRENT_BINARY_DIR}/include/soundtouch_config.h)

file(GLOB SOUNDTOUCH_SOURCES "${CMAKE_CURRENT_LIST_DIR}/source/SoundTouch/*.cpp")
add_library(libsoundtouch ${SOUNDTOUCH_SOURCES})
target_include_directories(libsoundtouch PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include")
target_include_directories(libsoundtouch PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/include")
set_target_properties(libsoundtouch PROPERTIES OUTPUT_NAME SoundTouch${TYPE_SUFFIX}${ARCH_SUFFIX})
if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_definitions(libsoundtouch PRIVATE -DDLL_EXPORTS)
    target_sources(libsoundtouch PRIVATE
        "${CMAKE_CURRENT_LIST_DIR}/source/SoundTouchDLL/SoundTouchDLL.cpp"
        "${CMAKE_CURRENT_LIST_DIR}/source/SoundTouchDLL/SoundTouchDLL.rc"
    )
endif()

install(TARGETS libsoundtouch
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
