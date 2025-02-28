if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} requires the following libraries from the system package manager:\n    libxmu-dev\n    libxi-dev\n    libgl-dev\n\nThese can be installed on Ubuntu systems via apt-get install libxmu-dev libxi-dev libgl-dev.")
endif()

# Don't change to vcpkg_from_github! The sources in the git repository (archives) are missing some files that are distributed inside releases.
# More info: https://github.com/nigels-com/glew/issues/31 and https://github.com/nigels-com/glew/issues/13
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0.tgz"
    FILENAME "glew-2.2.0.tgz"
    SHA512 57453646635609d54f62fb32a080b82b601fd471fcfd26e109f479b3fef6dfbc24b83f4ba62916d07d62cd06d1409ad7aa19bc1cd7cf3639c103c815b8be31d1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    SOURCE_BASE glew
    PATCHES
        fix-LNK2019.patch
        base_address.patch # Accepted upstream as https://github.com/nigels-com/glew/commit/ef7d12ecb7f1f336f6d3a80cebd6163b2c094108
        cmake_version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build/cmake"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_UTILS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glew)
# Skip check the required dependency opengl
vcpkg_fixup_pkgconfig(SKIP_CHECK)

# Burn-in CMake build config
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/GL/glew.h" "ifndef GLEW_NO_GLU" "if 0")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
set(_targets_cmake_files)
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    list(APPEND _targets_cmake_files "${CURRENT_PACKAGES_DIR}/share/glew/glew-targets-debug.cmake")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND _targets_cmake_files "${CURRENT_PACKAGES_DIR}/share/glew/glew-targets-release.cmake")
endif()

foreach(FILE ${_targets_cmake_files})
    file(READ ${FILE} _contents)
    string(REPLACE "libglew32" "glew32" _contents "${_contents}")
    file(WRITE ${FILE} "${_contents}")
endforeach()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/libglew32.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libglew32.lib" "${CURRENT_PACKAGES_DIR}/lib/glew32.lib")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libglew32d.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libglew32d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/glew32d.lib")
endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    foreach(FILE "${CURRENT_PACKAGES_DIR}/include/GL/glew.h" "${CURRENT_PACKAGES_DIR}/include/GL/wglew.h" "${CURRENT_PACKAGES_DIR}/include/GL/glxew.h")
        file(READ ${FILE} _contents)
        string(REPLACE "#ifdef GLEW_STATIC" "#if 1" _contents "${_contents}")
        file(WRITE ${FILE} "${_contents}")
    endforeach()
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
