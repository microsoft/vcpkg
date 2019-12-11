include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/sdformat
    REF sdformat6_6.2.0
    SHA512 3e3934010438bffbf10c1df29bd486c098e3c1bdf2b0349b69a53fb6f4d2bd3b3c8c4b4a8dfb413da13a638c0794f41c1bff4adb11a889b1552d90ba8b94c495
    HEAD_REF sdf6
)

# Ruby is required by the sdformat build process
vcpkg_find_acquire_program(RUBY)
get_filename_component(RUBY_PATH ${RUBY} DIRECTORY)
set(_path $ENV{PATH})
vcpkg_add_to_path(${RUBY_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTING=OFF
            -DUSE_EXTERNAL_URDF=ON
            -DUSE_EXTERNAL_TINYXML=ON
)

vcpkg_install_cmake()

# Restore original path
set(ENV{PATH} ${_path})

# Move location of sdformat.dll from lib to bin
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/sdformat.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/sdformat.dll
                ${CURRENT_PACKAGES_DIR}/bin/sdformat.dll)
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/sdformat.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sdformat.dll
                ${CURRENT_PACKAGES_DIR}/debug/bin/sdformat.dll)
endif()

# Fix cmake targets location
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/sdformat")

# Remove debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdformat6 RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME SDFormat)
