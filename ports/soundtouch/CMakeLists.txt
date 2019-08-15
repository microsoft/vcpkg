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

file(GLOB SOUNDTOUCH_SOURCES source/SoundTouch/*.cpp)
add_library(libsoundtouch ${SOUNDTOUCH_SOURCES})
target_include_directories(libsoundtouch PUBLIC include)
set_target_properties(libsoundtouch PROPERTIES OUTPUT_NAME SoundTouch${TYPE_SUFFIX}${ARCH_SUFFIX})
if(BUILD_SHARED_LIBS)
    target_compile_definitions(libsoundtouch PRIVATE -DDLL_EXPORTS)
    target_sources(libsoundtouch PRIVATE
        source/SoundTouchDLL/SoundTouchDLL.cpp
        source/SoundTouchDLL/SoundTouchDLL.rc
    )
endif()

install(TARGETS libsoundtouch
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
