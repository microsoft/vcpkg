# Patches that are independent of --head flag
set(_PATCHES 001-tools-path.patch)

# Patches that are only applied to --head builds
if(VCPKG_USE_HEAD_VERSION)
    list(APPEND _PATCHES 002-sdl-includes-head.patch)

# Patches that are only applied to release builds
else()
    list(APPEND _PATCHES 002-sdl-includes.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum
    REF v2019.10
    SHA512 b1c991199fa9b09b780ea822de4b2251c70fcc95e7f28bb14a6184861d92fcd4c6e6fe43ad21acfbfd191cd46e79bf58b867240ad6f706b07cd1fbe145b8eaff
    HEAD_REF master
    PATCHES
        ${_PATCHES}
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

# Drop a copy of tools
if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(EXE_SUFFIX .exe)
else()
    set(EXE_SUFFIX)
endif()

if(distancefieldconverter IN_LIST FEATURES)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/magnum-distancefieldconverter${EXE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/magnum)
endif()
if(fontconverter IN_LIST FEATURES)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/magnum-fontconverter${EXE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/magnum)
endif()
if(al-info IN_LIST FEATURES)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/magnum-al-info${EXE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/magnum)
endif()
if(magnuminfo IN_LIST FEATURES)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/magnum-info${EXE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/magnum)
endif()

# Tools require dlls
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/magnum)

file(GLOB_RECURSE TO_REMOVE
   ${CURRENT_PACKAGES_DIR}/bin/*${EXE_SUFFIX}
   ${CURRENT_PACKAGES_DIR}/debug/bin/*${EXE_SUFFIX})
if(TO_REMOVE)
    file(REMOVE ${TO_REMOVE})
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
