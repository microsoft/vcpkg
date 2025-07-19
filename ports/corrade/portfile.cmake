vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/corrade
    REF v2020.06
    SHA512 94cc8959b0ee43ecd8d13a25307e7829d53dc6601628d97c32288d1704e2c0835b755bffc06b2105e6aa5a612f119a60e83cb475860b51e6a35999215c100227
    HEAD_REF master
    PATCHES
        fix-vs2019.patch
        build-corrade-rc-always.patch
        clang-16.patch
        missing-headers.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

if(VCPKG_USE_HEAD_VERSION)
    set(_OPTION_PREFIX CORRADE_)
else()
    set(_OPTION_PREFIX )
endif()

# Handle features
set(_COMPONENTS "")
foreach(_feature IN LISTS ALL_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Final feature is empty, ignore it
    if(_feature AND NOT "${_feature}" STREQUAL "dynamic-pluginmanager")
        list(APPEND _COMPONENTS ${_feature} ${_OPTION_PREFIX}WITH_${_FEATURE})
    endif()
endforeach()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES ${_COMPONENTS})

set(corrade_rc_param "")
if(VCPKG_CROSSCOMPILING)
    set(corrade_rc_param
        "-DCORRADE_RC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/corrade/corrade-rc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(USE_ANSI_COLORS_ON_WINDOWS -D${_OPTION_PREFIX}UTILITY_USE_ANSI_COLORS=ON)
else()
    set(USE_ANSI_COLORS_ON_WINDOWS )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "${corrade_rc_param}"
        ${USE_ANSI_COLORS_ON_WINDOWS}
        -D${_OPTION_PREFIX}BUILD_STATIC=${BUILD_STATIC}
    MAYBE_UNUSED_VARIABLES
        CORRADE_RC_EXECUTABLE
)

vcpkg_cmake_install()

# Debug includes and share are the same as release
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# corrade-rc is not built when CMAKE_CROSSCOMPILING
vcpkg_copy_tools(TOOL_NAMES "corrade-rc" AUTO_CLEAN)

# Ensure no empty folders are left behind
if(FEATURES STREQUAL "core")
    # No features, no libs (only Corrade.h).
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/lib"
        "${CURRENT_PACKAGES_DIR}/debug")
    # debug is completely empty, as include and share
    # have already been removed.

elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # No dlls
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)

vcpkg_copy_pdbs()
