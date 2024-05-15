# Don't file if the bin folder exists. We need exe and custom files.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

message(STATUS [=[
The usd port does not work with the version of Threading Building Blocks (tbb) currently chosen by vcpkg's baselines,
and does not expect to be updated to work with current versions soon. See
https://github.com/PixarAnimationStudios/USD/issues/1600

If you must use this port in your project, pin a version of tbb of 2020_U3 or older via a manifest file.
See https://vcpkg.io/en/docs/examples/versioning.getting-started.html for instructions.
]=])

string(REGEX REPLACE "^([0-9]+)[.]([0-9])\$" "\\1.0\\2" USD_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/OpenUSD
    REF "v${USD_VERSION}"
    SHA512 e510f6421caba5e74c6efe5b56b17e9c9741ece0cfd5020148ca89b3ac32bd8781ab00dfc7a134163c85af3f4f01f2529a9baa5a9df9b0c80cbca003e6d199e2
    HEAD_REF master
    PATCHES
        fix_build-location.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindTBB.cmake)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPXR_BUILD_ALEMBIC_PLUGIN:BOOL=OFF
        -DPXR_BUILD_EMBREE_PLUGIN:BOOL=OFF
        -DPXR_BUILD_IMAGING:BOOL=OFF
        -DPXR_BUILD_MONOLITHIC:BOOL=OFF
        -DPXR_BUILD_TESTS:BOOL=OFF
        -DPXR_BUILD_USD_IMAGING:BOOL=OFF
        -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=OFF
        -DPXR_BUILD_EXAMPLES:BOOL=OFF
        -DPXR_BUILD_TUTORIALS:BOOL=OFF
        -DPXR_BUILD_USD_TOOLS:BOOL=OFF
)

vcpkg_cmake_install()

# The CMake files installation is not standard in USD and will install pxrConfig.cmake in the prefix root and
# pxrTargets.cmake in "cmake" so we are moving pxrConfig.cmake in the same folder and patch the path to pxrTargets.cmake
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/pxrConfig.cmake "/cmake/pxrTargets.cmake" "/pxrTargets.cmake")

file(
    RENAME
        "${CURRENT_PACKAGES_DIR}/pxrConfig.cmake"
        "${CURRENT_PACKAGES_DIR}/cmake/pxrConfig.cmake")

vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME pxr)

# Remove duplicates in debug folder
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/pxrConfig.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.txt)

if(VCPKG_TARGET_IS_WINDOWS)
    # Move all dlls to bin
    file(GLOB RELEASE_DLL ${CURRENT_PACKAGES_DIR}/lib/*.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(GLOB DEBUG_DLL ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    foreach(CURRENT_FROM ${RELEASE_DLL} ${DEBUG_DLL})
        string(REPLACE "/lib/" "/bin/" CURRENT_TO ${CURRENT_FROM})
        file(RENAME ${CURRENT_FROM} ${CURRENT_TO})
    endforeach()

    vcpkg_copy_pdbs()

    function(file_replace_regex filename match_string replace_string)
        file(READ ${filename} _contents)
        string(REGEX REPLACE "${match_string}" "${replace_string}" _contents "${_contents}")
        file(WRITE ${filename} "${_contents}")
    endfunction()

    # fix dll path for cmake
    file_replace_regex(${CURRENT_PACKAGES_DIR}/share/pxr/pxrTargets-debug.cmake "debug/lib/([a-zA-Z0-9_]+)\\.dll" "debug/bin/\\1.dll")
    file_replace_regex(${CURRENT_PACKAGES_DIR}/share/pxr/pxrTargets-release.cmake "lib/([a-zA-Z0-9_]+)\\.dll" "bin/\\1.dll")

    # fix plugInfo.json for runtime
    file(GLOB_RECURSE PLUGINFO_FILES ${CURRENT_PACKAGES_DIR}/lib/usd/*/resources/plugInfo.json)
    file(GLOB_RECURSE PLUGINFO_FILES_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib/usd/*/resources/plugInfo.json)
    foreach(PLUGINFO ${PLUGINFO_FILES} ${PLUGINFO_FILES_DEBUG})
        file_replace_regex(${PLUGINFO} [=["LibraryPath": "../../([a-zA-Z0-9_]+).dll"]=] [=["LibraryPath": "../../../bin/\1.dll"]=])
    endforeach()
endif()
