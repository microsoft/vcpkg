vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/sdformat
    REF sdformat6_6.2.0
    SHA512 3d139ec4b4c9fbfd547ed8bfca0adb5cdca92c1b7cc4d4b554a7c51ccf755b9079c26a006ebfedc5bc5b1ba5e16ad950bb38c47ea97bf97e59a2fd7d12d60620
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
