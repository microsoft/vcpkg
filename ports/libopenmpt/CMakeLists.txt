cmake_minimum_required(VERSION 3.9)
project(libopenmpt)

if(MSVC)
  add_compile_options(
    /W3 /wd4005 /wd4267 /wd4244 /wd4996 /wd4100 /wd4018
  )
  add_compile_definitions(
    _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE
    _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_WARNINGS
  )
endif()

find_package(ZLIB REQUIRED)
find_package(mpg123 CONFIG REQUIRED)
find_package(Vorbis REQUIRED)

file(GLOB HEADERS libopenmpt/*.h libopenmpt/*.hpp src/openmpt/all/*.hpp)
list(FILTER HEADERS EXCLUDE REGEX "_impl\\.hpp$|_internal\\.h$")

include_directories(
  .
  src
  build/svn_version
  libopenmpt
  common
  soundbase
  sounddsp
  soundlib
  openmpt123
)

file(GLOB_RECURSE SOURCES
  common/*.cpp
  soundbase/*.cpp
  sounddsp/*.cpp
  # Because this is a GLOB_RECURSE, soundlib/plugins/*.cpp will be included
  soundlib/*.cpp
  libopenmpt/libopenmpt_c.cpp
  libopenmpt/libopenmpt_cxx.cpp
  libopenmpt/libopenmpt_ext_impl.cpp
  libopenmpt/libopenmpt_impl.cpp
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(libopenmpt ${SOURCES})
set_target_properties(libopenmpt PROPERTIES OUTPUT_NAME openmpt)

target_compile_definitions(libopenmpt PRIVATE
  MPT_WITH_MPG123 MPT_WITH_OGG
  MPT_WITH_VORBIS MPT_WITH_VORBISFILE
  MPT_WITH_ZLIB MPT_BUILD_VCPKG
  LIBOPENMPT_BUILD
)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(
    libopenmpt
    PRIVATE LIBOPENMPT_BUILD_DLL
  )
endif()

target_include_directories(
  libopenmpt
  PUBLIC
    $<INSTALL_INTERFACE:include>
)

target_link_libraries(
  libopenmpt
  PRIVATE
    MPG123::libmpg123
    Vorbis::vorbisfile
    Vorbis::vorbis
    ZLIB::ZLIB
)
if(APPLE)
  target_link_libraries(libopenmpt PRIVATE c++)
endif()

set(LIBOPENMPT_REQUIRES_PRIVATE "zlib vorbis vorbisfile libmpg123")
set(LIBOPENMPT_LIBS_PRIVATE "")
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix [[${prefix}]])
set(includedir [[${prefix}/include]])
set(libdir [[${prefix}/lib]])
configure_file(libopenmpt/libopenmpt.pc.in libopenmpt.pc)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libopenmpt.pc DESTINATION lib/pkgconfig)

install(TARGETS libopenmpt EXPORT libopenmpt-targets)
install(EXPORT libopenmpt-targets DESTINATION share/libopenmpt NAMESPACE libopenmpt::)
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/libopenmpt-config.cmake [[
include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(mpg123 CONFIG)
find_dependency(Vorbis)
include(${CMAKE_CURRENT_LIST_DIR}/libopenmpt-targets.cmake)
]])
install(FILES ${HEADERS} DESTINATION include/libopenmpt)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libopenmpt-config.cmake DESTINATION share/libopenmpt)
