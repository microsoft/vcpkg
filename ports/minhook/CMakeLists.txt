cmake_minimum_required(VERSION 3.0)

project(minhook LANGUAGES C)

include(CMakePackageConfigHelpers)

set(MINHOOK_MAJOR_VERSION 1)
set(MINHOOK_MINOR_VERSION 3)
set(MINHOOK_PATCH_VERSION 3)
set(MINHOOK_VERSION ${MINHOOK_MAJOR_VERSION}.${MINHOOK_MINOR_VERSION}.${MINHOOK_PATCH_VERSION})

################
#    BUILD     # 
################

option(BUILD_SHARED_LIBS "build shared version" OFF)

set(SOURCES_MINHOOK 
  "src/buffer.c"
  "src/hook.c"
  "src/trampoline.c"
)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(SOURCES_HDE "src/hde/hde64.c")
else()
  set(SOURCES_HDE "src/hde/hde32.c")
endif()

if(BUILD_SHARED_LIBS)
  set(RESOURCES 
    "dll_resources/minhook.rc"
    "dll_resources/minhook.def"
  )
endif()

add_library(minhook ${SOURCES_MINHOOK} ${SOURCES_HDE} ${RESOURCES})

target_include_directories(minhook PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/>
  $<INSTALL_INTERFACE:include>
)

target_include_directories(minhook PRIVATE "src/")
target_include_directories(minhook PRIVATE "src/hde/")

if(WIN32)
  set_target_properties(minhook PROPERTIES PREFIX "")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)   
    set_target_properties(minhook PROPERTIES DEBUG_POSTFIX ".x64d")
    set_target_properties(minhook PROPERTIES RELEASE_POSTFIX ".x64")
    set_target_properties(minhook PROPERTIES RELWITHDEBINFO_POSTFIX ".x64")
    set_target_properties(minhook PROPERTIES MINSIZEREL_POSTFIX ".x64")
  else()
    set_target_properties(minhook PROPERTIES DEBUG_POSTFIX ".x32d")
    set_target_properties(minhook PROPERTIES RELEASE_POSTFIX ".x32")
    set_target_properties(minhook PROPERTIES RELWITHDEBINFO_POSTFIX ".x32")
    set_target_properties(minhook PROPERTIES MINSIZEREL_POSTFIX ".x64")
  endif()
else()
  set_target_properties(minhook PROPERTIES PREFIX "lib")
  set_target_properties(minhook PROPERTIES POSTFIX "")
  set_target_properties(minhook PROPERTIES DEBUG_POSTFIX "d")
endif()

################
# CMAKE CONFIG # 
################

configure_package_config_file(
    "cmake/minhook-config.cmake.in"
    "minhook-config.cmake"
  INSTALL_DESTINATION 
    "lib/minhook"
)

write_basic_package_version_file(
  "minhook-config-version.cmake"
VERSION 
  ${MINHOOK_VERSION}
COMPATIBILITY
  AnyNewerVersion
)

install(
  FILES 
    "${CMAKE_CURRENT_BINARY_DIR}/minhook-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/minhook-config-version.cmake"
  DESTINATION 
    share/minhook
)

###################
#     INSTALL     #
###################

install(TARGETS minhook
        EXPORT minhook-targets
        RUNTIME DESTINATION "bin"
        ARCHIVE DESTINATION "lib"
        LIBRARY DESTINATION "lib"
)

install(
  EXPORT
    minhook-targets
  NAMESPACE 
    minhook::
  DESTINATION 
    share/minhook
)

install(
  DIRECTORY include DESTINATION .
)