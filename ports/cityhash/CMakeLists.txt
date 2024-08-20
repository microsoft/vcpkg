cmake_minimum_required(VERSION 3.13)
project(cityhash CXX)

option(ENABLE_SSE "Build CityHash variants that depend on the _mm_crc32_u64 intrinsic." OFF)

set(CMAKE_CXX_STANDARD 11)

if (ENABLE_SSE)
    include (CMakePushCheckState)
    cmake_push_check_state()
    if (MSVC)
        include(CheckCXXSourceCompiles)
        
    check_cxx_source_compiles(
    "#include <nmmintrin.h>
    int main() {
        _mm_crc32_u64(0, 0);
        return 0;
    }"
    USE_SSE)
    else()
        include(CheckCXXCompilerFlag)
        check_cxx_compiler_flag ("-msse4.2" USE_SSE)
        if (USE_SSE)
            set (SSE2_FLAG "-msse4.2")
        endif()
    endif()
    
    cmake_pop_check_state()
    
    if (NOT USE_SSE)
        message(FATAL_ERROR "This platform doesn't support feature SSE4.2")
    endif()
else()
    set(USE_SSE OFF)
endif()

add_library(cityhash STATIC src/city.cc)

list(APPEND CITY_HEADERS src/city.h)
if (USE_SSE)
    list(APPEND CITY_HEADERS src/citycrc.h)

    target_compile_options(cityhash PRIVATE ${SSE2_FLAG})
    if (MSVC)
        target_compile_definitions(cityhash PRIVATE __SSE4_2__)
    endif()
endif()

target_include_directories(cityhash PUBLIC
	$<INSTALL_INTERFACE:include>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
)

install(TARGETS cityhash EXPORT cityhash-config 
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(EXPORT cityhash-config DESTINATION share/cmake/cityhash)
install(FILES ${CITY_HEADERS} DESTINATION include)
