# Mark variables as used so cmake doesn't complain about them
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# This is a backport of CMAKE_TRY_COMPILE_PLATFORM_VARIABLES to cmake 3.0
get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if( _CMAKE_IN_TRY_COMPILE )
    include( "${CMAKE_CURRENT_SOURCE_DIR}/../vcpkg.config.cmake" OPTIONAL )
endif()

if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
endif()

if(VCPKG_TOOLCHAIN)
    return()
endif()

set(_VCPKG_TOOLCHAIN_DIR ${CMAKE_CURRENT_LIST_DIR})
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-msg.cmake)

if(NOT VCPKG_TARGET_TRIPLET)
    include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-default_triplet.cmake)
    vcpkg_msg(WARNING toolchain "Target triplet not specified! Default is: ${VCPKG_TARGET_TRIPLET}! If you want to change it please delete the cache and rerun CMake with -DVCPKG_TARGET_TRIPLET=<triplet>" ALWAYS)
    #Cleaning the cache is required so that cmake actually reruns find_ calls; Should probably be made a FATAL_ERROR instead. 
endif()

if(NOT DEFINED _VCPKG_ROOT_DIR)
    # Detect .vcpkg-root to figure VCPKG_ROOT_DIR
    set(_VCPKG_ROOT_DIR_CANDIDATE ${CMAKE_CURRENT_LIST_DIR})
    while(IS_DIRECTORY ${_VCPKG_ROOT_DIR_CANDIDATE} AND NOT EXISTS "${_VCPKG_ROOT_DIR_CANDIDATE}/.vcpkg-root")
        get_filename_component(_VCPKG_ROOT_DIR_TEMP ${_VCPKG_ROOT_DIR_CANDIDATE} DIRECTORY)
        if (_VCPKG_ROOT_DIR_TEMP STREQUAL _VCPKG_ROOT_DIR_CANDIDATE) # If unchanged, we have reached the root of the drive
            vcpkg_msg(FATAL_ERROR toolchain "Could not find .vcpkg-root" ALWAYS)
        else()
            SET(_VCPKG_ROOT_DIR_CANDIDATE ${_VCPKG_ROOT_DIR_TEMP})
        endif()
    endwhile()
    set(_VCPKG_ROOT_DIR ${_VCPKG_ROOT_DIR_CANDIDATE} CACHE INTERNAL "Vcpkg root directory")
endif()
set(_VCPKG_INSTALLED_DIR ${_VCPKG_ROOT_DIR}/installed)

if(NOT EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" AND NOT _CMAKE_IN_TRY_COMPILE)
    vcpkg_msg(WARNING toolchain "There are no libraries installed for the vcpkg triplet ${VCPKG_TARGET_TRIPLET}." ALWAYS)
endif()

include(CMakeDependentOption)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-setup_cmake_paths.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-add_executable.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-add_library.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-find_package.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-find_library.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-set_property.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-set_target_properties.cmake)

set(VCPKG_TOOLCHAIN ON)

#Silence CMake?
set(_UNUSED ${CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION})
set(_UNUSED ${CMAKE_EXPORT_NO_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP})

#Backport?
if(NOT _CMAKE_IN_TRY_COMPILE)
    file(TO_CMAKE_PATH "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" _chainload_file)
    file(TO_CMAKE_PATH "${_VCPKG_ROOT_DIR}" _root_dir)
    file(WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/vcpkg.config.cmake"
        "set(VCPKG_TARGET_TRIPLET \"${VCPKG_TARGET_TRIPLET}\" CACHE STRING \"\")\n"
        "set(VCPKG_APPLOCAL_DEPS \"${VCPKG_APPLOCAL_DEPS}\" CACHE STRING \"\")\n"
        "set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE \"${_chainload_file}\" CACHE STRING \"\")\n"
        "set(_VCPKG_ROOT_DIR \"${_root_dir}\" CACHE STRING \"\")\n"
        )
endif()
