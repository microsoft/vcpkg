include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME)
    # The library supports Linux/Darwin/BSD, it is just not yet added here
    message(FATAL_ERROR "vcpkg libfabric currently suports windows.  Please consider a pull request to add additional support!")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ofiwg/libfabric
    REF v1.8.1
    HEAD_REF master
    SHA512 7c3879af3ad7dbda9e9bf9f43a2d213a8e41d50212008f29e912d3d0946efc381e6833c08206106e9f486c37eaef16103198247b328297209ef80dc66ca1b6e5
    PATCHES
      add_additional_includes.patch
)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
   message(FATAL_ERROR "VCPKG BUILD ERROR: libfabric only supports x64")
endif()

set(LIBFABRIC_RELEASE_CONFIGURATION "Release-v141")
set(LIBFABRIC_DEBUG_CONFIGURATION "Debug-v141")

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libfabric.vcxproj
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    PLATFORM "x64"
    RELEASE_CONFIGURATION ${LIBFABRIC_RELEASE_CONFIGURATION}
    DEBUG_CONFIGURATION ${LIBFABRIC_RELEASE_CONFIGURATION}
    USE_VCPKG_INTEGRATION
    ALLOW_ROOT_INCLUDES
    OPTIONS
      /p:SolutionDir=${SOURCE_PATH}
      /p:AdditionalIncludeDirectories="${CURRENT_INSTALLED_DIR}/include"
)

#Move includes under subdirectory to avoid colisions with other libraries
file(RENAME ${CURRENT_PACKAGES_DIR}/include ${CURRENT_PACKAGES_DIR}/includetemp)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/includetemp ${CURRENT_PACKAGES_DIR}/include/libfabric)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libfabric RENAME copyright)
