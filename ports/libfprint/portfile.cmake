vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfprint/libfprint
    REF master
    SHA512 7cb01e6cdd66c93ad956cc20e6cae6699d23c801a158c7c7e0d0b0299c90abeca7a71939691a731a69d0a8dc530721083b672de9710830dda41932f300874bea
    HEAD_REF master
)

# Apply platform-specific patches
# Windows: comprehensive MSVC build fixes
# macOS: disable version-script for darwin and fix overflow (libfprint only)
# Android: fix overflow (libfprint only, check if gusb needs patches)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_apply_patches(
        SOURCE_PATH "${SOURCE_PATH}"
        PATCHES
            fix-windows-build.patch
    )
elseif(VCPKG_TARGET_IS_OSX)
    vcpkg_apply_patches(
        SOURCE_PATH "${SOURCE_PATH}"
        PATCHES
            fix-macos-build.patch
    )
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
    vcpkg_apply_patches(
        SOURCE_PATH "${SOURCE_PATH}"
        PATCHES
            fix-android-build.patch
    )
endif()
# Linux and other Unix-like systems should work without patches (native support)

# Configure Meson with platform-specific options
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_configure_meson(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -Ddoc=false
            -Dgtk-examples=false
            -Dudev_rules=disabled
            -Dudev_hwdb=disabled
            -Dintrospection=false
            -Dtests=false
        OPTIONS_DEBUG
            -Dc_args="/std:c11"
            -Dc_args="-DLIBFPRINT_COMPILATION"
        OPTIONS_RELEASE
            -Dc_args="/std:c11"
            -Dc_args="-DLIBFPRINT_COMPILATION"
    )
else()
    # macOS/OSX, Linux, Android and other Unix-like systems
    # Use default Meson options - libfprint natively supports these platforms
    # Linux may need udev rules, but vcpkg typically handles this separately
    vcpkg_configure_meson(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -Ddoc=false
            -Dgtk-examples=false
            -Dudev_rules=disabled
            -Dudev_hwdb=disabled
            -Dintrospection=false
            -Dtests=false
    )
endif()

# Fix Meson bug: remove "csr" from LINK_ARGS for static libraries on Windows ARM64
# This is a known Meson bug that incorrectly sets LINK_ARGS="csr" for MSVC static libraries
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    find_program(POWERSHELL_EXE powershell.exe REQUIRED)
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/build.ninja")
        vcpkg_execute_required_process(
            COMMAND "${POWERSHELL_EXE}" -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_LIST_DIR}/fix-meson-csr.ps1" -BuildDir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            LOGNAME "fix-meson-csr-dbg"
        )
    endif()
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/build.ninja")
        vcpkg_execute_required_process(
            COMMAND "${POWERSHELL_EXE}" -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_LIST_DIR}/fix-meson-csr.ps1" -BuildDir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            LOGNAME "fix-meson-csr-rel"
        )
    endif()
endif()

vcpkg_install_meson()

# Remove debug/share as it contains only test files which are not needed
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
