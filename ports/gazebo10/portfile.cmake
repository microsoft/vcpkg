include(vcpkg_common_functions)
 
vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/gazebo
    REF gazebo10_10.1.0
    SHA512 7170ed87190e94e170cdcd4fad1c9e038ee2ba8979ed8187cb8e702ddd5d920f9c1a627e88ce200ecfae77a3d81fc156712beab325fe006da013386bbcd7517b
    HEAD_REF gazebo10
    # Ensure that pkg-config is not requirex on MSVC (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3125)
    PATCHES fix-pkg-config-msvc-workaround.patch
    # Fix find_package(OGRE) logic (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3126)
            fix-find-package-ogre.patch
    # Fix missing link of ignition-common in gazebo_common (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3127)
            fix-link-ignition-common.patch
    # Fix compilation of gazebo rendering with Ogre 1.12 (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3129)
            gazebo-rendering-support-ogre-1-12.patch
    # Fix compilation of gazebo::rendering::Heightmap with Ogre 1.12 (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3130)
            gazebo-rendering-heightmap-support-ogre-1-12.patch
    # Fix compilation with Ogre in debug mode, part 1 (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3131)
            gazebo-3131.patch
    # Fix compilation with Ogre in debug mode, part 2 (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3134)
            gazebo-3134.patch
    # Avoid to pass GCC style linker options to Visual Studio Linker (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3141)
            gazebo-3141.patch
    # Fix compilation with Ogre in debug mode, part 3 (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3142)
            gazebo-3142.patch
    # Add support for finding TBB via CMake config files (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3135)
            gazebo-3135.patch
    # Install dll in <prefix>/bin (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3144)
            gazebo-3144.patch
    #  Avoid conflict between winnt.h's DELETE and ignition::fuel_tools::REST::DELETE  (backport of https://bitbucket.org/osrf/gazebo/pull-requests/3143)
            gazebo-3143.patch
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS -DBUILD_TESTING=OFF
)

# This port needs  to generate protobuf messages with a custom plugin generator,
# so it needs to have in Windows the relative protobuf dll available in the PATH
set(path_backup $ENV{PATH})
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)

vcpkg_install_cmake()

# Restore old path
set(ENV{PATH} "${path_backup}")

# Fix cmake targets location
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/gazebo" TARGET_PATH "share/gazebo10")

# Handle executables installation
set(GAZEBO_EXECUTABLES gz gzserver gzclient)

if (VCPKG_TARGET_IS_WINDOWS)
  set(EXECUTABLE_SUFFIX ".exe")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  foreach(tool ${GAZEBO_EXECUTABLES})
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/${tool}${EXECUTABLE_SUFFIX}"
         DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gazebo10/release)
  endforeach()
  vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/gazebo10/release)
  foreach(tool ${GAZEBO_EXECUTABLES})
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${tool}${EXECUTABLE_SUFFIX}")
  endforeach()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  foreach(tool ${GAZEBO_EXECUTABLES})
    file(COPY "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${EXECUTABLE_SUFFIX}"
         DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gazebo10/debug)
  endforeach()
  vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/gazebo10/debug)
  foreach(tool ${GAZEBO_EXECUTABLES})
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${EXECUTABLE_SUFFIX}")
  endforeach()
endif()

# Remove debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include 
                    ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gazebo10 RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME gazebo)