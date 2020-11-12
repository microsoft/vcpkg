vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum
    REF v2020.06
    SHA512 65b0c8a4520d1d282420c30ecd7c8525525d4dbb6e562e1e2e93d110f4eb686af43f098bf02460727fab1e1f9446dd00a99051e150c05ea40b1486a44fea1042
    HEAD_REF master
    PATCHES
        001-tools-path.patch
        002-sdl-includes.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC 1)
    set(BUILD_PLUGINS_STATIC 1)
else()
    set(BUILD_STATIC 0)
    set(BUILD_PLUGINS_STATIC 0)
endif()

# Remove platform-specific feature that are not available
# on current target platform from all features.

# For documentation on VCPKG_CMAKE_SYSTEM_NAME see
# https://github.com/microsoft/vcpkg/blob/master/docs/users/triplets.md#vcpkg_cmake_system_name

set(ALL_SUPPORTED_FEATURES ${ALL_FEATURES})
# Windows Desktop
if(NOT "${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
    list(REMOVE_ITEM ALL_SUPPORTED_FEATURES wglcontext windowlesswglapplication)
endif()

# Universal Windows Platform
if(NOT "${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "WindowsStore")
    # No UWP specific features
endif()

# Mac OSX
if(NOT "${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    list(REMOVE_ITEM ALL_SUPPORTED_FEATURES cglcontext windowlesscglapplication)
endif()

# Linux
if(NOT "${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    list(REMOVE_ITEM ALL_SUPPORTED_FEATURES glxcontext windowlessglxapplication)
endif()

# WebAssembly / Linux
if(NOT "${VCPKG_CMAKE_SYSTEM_NAME}" MATCHES "(Emscripten|Linux)")
    list(REMOVE_ITEM ALL_SUPPORTED_FEATURES eglcontext windowlesseglapplication)
endif()

set(_COMPONENTS "")
# Generate cmake parameters from feature names
foreach(_feature IN LISTS ALL_SUPPORTED_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Final feature is empty, ignore it
    if(_feature)
        list(APPEND _COMPONENTS ${_feature} WITH_${_FEATURE})
    endif()
endforeach()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS ${_COMPONENTS})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_PLUGINS_STATIC=${BUILD_PLUGINS_STATIC}
        -DMAGNUM_PLUGINS_DEBUG_DIR=${CURRENT_INSTALLED_DIR}/debug/bin/magnum-d
        -DMAGNUM_PLUGINS_RELEASE_DIR=${CURRENT_INSTALLED_DIR}/bin/magnum
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Copy tools into vcpkg's tools directory
set(_TOOL_EXEC_NAMES "")
set(_TOOLS
    al-info
    distancefieldconverter
    fontconverter
    gl-info
    imageconverter
    sceneconverter)
foreach(_tool IN LISTS _TOOLS)
    if("${_tool}" IN_LIST FEATURES)
        list(APPEND _TOOL_EXEC_NAMES magnum-${_tool})
    endif()
endforeach()
message(STATUS ${_TOOL_EXEC_NAMES})
if(_TOOL_EXEC_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${_TOOL_EXEC_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
   # move plugin libs to conventional place
   file(GLOB_RECURSE LIB_TO_MOVE ${CURRENT_PACKAGES_DIR}/lib/magnum/*)
   file(COPY ${LIB_TO_MOVE} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/magnum)
   file(GLOB_RECURSE LIB_TO_MOVE_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/magnum/*)
   file(COPY ${LIB_TO_MOVE_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/magnum)
else()
   file(COPY ${CMAKE_CURRENT_LIST_DIR}/magnumdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/bin/magnum)
   file(COPY ${CMAKE_CURRENT_LIST_DIR}/magnumdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/magnum-d)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
