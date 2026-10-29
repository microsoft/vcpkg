# Unofficial perfetto CMakeLists.txt from https://github.com/google/perfetto/blob/v43.1/meson.build
cmake_minimum_required(VERSION 3.23)
project(perfetto LANGUAGES CXX)

add_library(perfetto)
target_compile_features(perfetto PRIVATE cxx_std_17)
target_sources(perfetto
    PRIVATE "sdk/perfetto.cc"
    PUBLIC FILE_SET HEADERS BASE_DIRS "sdk" FILES "sdk/perfetto.h"
)

set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)
target_link_libraries(perfetto PRIVATE Threads::Threads)

if(ANDROID)
    target_link_libraries(perfetto PRIVATE log)
endif(ANDROID)

if(WIN32)
    target_compile_options(perfetto PRIVATE "/bigobj")
    target_compile_definitions(perfetto PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX)
    target_link_libraries(perfetto PRIVATE ws2_32)
endif(WIN32)

if(MSVC)
    target_compile_options(perfetto PRIVATE "/permissive-")
endif(MSVC)

install(TARGETS perfetto
    EXPORT unofficial-perfetto-config
    FILE_SET HEADERS DESTINATION "include"
)

install(EXPORT unofficial-perfetto-config
    NAMESPACE unofficial::perfetto::
    DESTINATION "share/unofficial-perfetto"
)

install(FILES "protos/perfetto/trace/perfetto_trace.proto" DESTINATION "share/unofficial-perfetto")
