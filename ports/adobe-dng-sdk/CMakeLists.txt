cmake_minimum_required(VERSION 3.21)
project(dng_sdk)

set(Upstream_VERSION "1.7.1")

#
# DNG SDK
#
set(DNG_SOURCE_DIR ${PROJECT_SOURCE_DIR}/dng_sdk/source)
file(GLOB DNG_SOURCE ${DNG_SOURCE_DIR}/*.cpp)
file(GLOB DNG_HEADERS ${DNG_SOURCE_DIR}/*.h)
list(REMOVE_ITEM DNG_SOURCE ${DNG_SOURCE_DIR}/dng_validate.cpp)
add_library(dng STATIC ${DNG_SOURCE})

set_property(TARGET dng PROPERTY VERSION "${Upstream_VERSION}")
set_property(TARGET dng PROPERTY INTERFACE_dng_MAJOR_VERSION 1)
set_property(TARGET dng PROPERTY COMPATIBLE_INTERFACE_STRING 1)

find_package(ZLIB REQUIRED)
target_link_libraries(dng PRIVATE ZLIB::ZLIB)

target_include_directories(dng PUBLIC $<BUILD_INTERFACE:${DNG_SOURCE_DIR}>)
target_compile_definitions(dng PUBLIC $<$<PLATFORM_ID:Android>:qAndroid=1> $<$<PLATFORM_ID:Darwin>:qMacOS=1>
                                      $<$<PLATFORM_ID:Linux>:qLinux=1> $<$<PLATFORM_ID:Windows>:qWinOS=1>)

#
# Threading support
#
find_package(Threads REQUIRED)
target_link_libraries(dng PRIVATE Threads::Threads)
target_compile_definitions(dng PUBLIC qDNGThreadSafe=1)

#
# JPEG
#
find_package(JPEG REQUIRED)
target_link_libraries(dng PRIVATE JPEG::JPEG)
target_compile_definitions(dng PUBLIC qDNGUseLibJPEG=1)

#
# XMP
#
find_package(EXPAT REQUIRED)

set(XMP_ROOT ${PROJECT_SOURCE_DIR}/xmp/toolkit)
file(GLOB XMP_SOURCE ${XMP_ROOT}/source/*.cpp)
if (WIN32)
    list(REMOVE_ITEM XMP_SOURCE ${XMP_ROOT}/source/Host_IO-POSIX.cpp)
elseif (UNIX)
    list(REMOVE_ITEM XMP_SOURCE ${XMP_ROOT}/source/Host_IO-Win.cpp)
endif()
file(GLOB XMP_CORE ${XMP_ROOT}/XMPCore/source/*.cpp)
file(GLOB XMP_COMMON ${XMP_ROOT}/XMPCommon/source/*.cpp)
file(GLOB XMP_ZUID ${XMP_ROOT}/third-party/zuid/sources/*.cpp)

add_library(xmp STATIC ${XMP_SOURCE} ${XMP_CORE} ${XMP_COMMON} ${XMP_ZUID})
target_link_libraries(xmp PRIVATE EXPAT::EXPAT)
target_include_directories(
    xmp
    PUBLIC $<BUILD_INTERFACE:${XMP_ROOT}/public/include>
    PRIVATE ${XMP_ROOT})
target_compile_definitions(
    xmp
    PUBLIC $<$<PLATFORM_ID:Darwin>:MAC_ENV> $<$<PLATFORM_ID:Linux>:UNIX_ENV> $<$<PLATFORM_ID:Windows>:WIN_ENV>
    PRIVATE $<$<PLATFORM_ID:Windows>:XMP_WinBuild> $<$<PLATFORM_ID:Linux>:XMP_UNIXBuild>
    PRIVATE XMP_StaticBuild
    PRIVATE XMP_COMPONENT_INT_NAMESPACE=AdobeXMPCore_Int)
if(UNIX)
    find_package(Boost REQUIRED COMPONENTS uuid)
    target_link_libraries(xmp PRIVATE Boost::uuid)
endif()

target_link_libraries(dng PRIVATE xmp)
target_compile_definitions(dng PUBLIC qDNGUseXMP=1 qDNGXMPFiles=0 qDNGXMPDocOps=0)

#
# JXL
#
# NOTE: For pkg_check_module to correctly create libjxl under PkgConfig::*,
# IMPORTED_TARGET is required.
find_package(PkgConfig REQUIRED)
pkg_check_modules(libjxl REQUIRED IMPORTED_TARGET libjxl libjxl_threads)
target_link_libraries(dng PRIVATE PkgConfig::libjxl)

set(PORT_PACKAGE_NAME dngsdk)

install(TARGETS dng xmp EXPORT ${PORT_PACKAGE_NAME}Targets
    RUNTIME  DESTINATION bin
    ARCHIVE  DESTINATION lib
    LIBRARY  DESTINATION lib
)

install(
  FILES
    ${DNG_HEADERS}
  DESTINATION
    include
  COMPONENT
    Devel
)

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${PORT_PACKAGE_NAME}ConfigVersion.cmake"
  VERSION ${Upstream_VERSION}
  COMPATIBILITY AnyNewerVersion
)

export(EXPORT ${PORT_PACKAGE_NAME}Targets
  FILE "${CMAKE_CURRENT_BINARY_DIR}/${PORT_PACKAGE_NAME}Targets.cmake"
  NAMESPACE ${PORT_PACKAGE_NAME}::
)

configure_file(${PORT_PACKAGE_NAME}Config.cmake
  "${CMAKE_CURRENT_BINARY_DIR}/${PORT_PACKAGE_NAME}Config.cmake"
  COPYONLY
)

# Generate the dngsdkTargets.cmake file directly at the install location
install(EXPORT ${PORT_PACKAGE_NAME}Targets
  FILE
    ${PORT_PACKAGE_NAME}Targets.cmake
  NAMESPACE
    ${PORT_PACKAGE_NAME}::
  DESTINATION
    "share/${PORT_PACKAGE_NAME}"
)

# Copy previously-generated Config.cmake and ConfigVersion.cmake to the install location
install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PORT_PACKAGE_NAME}Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PORT_PACKAGE_NAME}ConfigVersion.cmake"
  DESTINATION
    "share/${PORT_PACKAGE_NAME}"
  COMPONENT
    Devel
)

if(WITH_DNG_VALIDATE)
    add_executable(dng_validate
        ${DNG_SOURCE_DIR}/dng_validate.cpp
        # NOTE: Required because dng_validate is supposed to be built with slightly
        # different flags, and if this file is not present this creates missing symbols.
        ${DNG_SOURCE_DIR}/dng_globals.cpp
    )
    target_link_libraries(dng_validate PRIVATE dng)
    target_link_libraries(dng_validate PRIVATE xmp)
    target_link_libraries(dng_validate PRIVATE PkgConfig::libjxl)
    # NOTE: the qDNGValidate flag is required to build the executable, but this
    # should in principle require recompiling the dng library target as it affects
    # other .cpp sources than dng_validate.cpp... Not bothering for now.
    target_compile_definitions(dng_validate PUBLIC qDNGValidateTarget=1 qDNGValidate=1)

    install(TARGETS dng_validate
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
    )
endif()