# Determine patches to apply based on platform
set(PATCHES_TO_APPLY "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PATCHES_TO_APPLY fix-windows-build.patch)
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND PATCHES_TO_APPLY fix-macos-build.patch)
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
    list(APPEND PATCHES_TO_APPLY fix-android-build.patch)
endif()
# Linux and other Unix-like systems should work without patches (native support)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfprint/libfprint
    REF 596b5f803238dd877c2c262833a7dfcf14f4ed91
    SHA512 0618e3850ad07a757d185d5ce12785d6cadc69f35f4f0f48016fa07abfed2a36b166dbc4b96c77d13224a831b25b17d023427c9912c93df837e45f20d44bf93e
    HEAD_REF master
    PATCHES ${PATCHES_TO_APPLY}
)

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
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
    # Android: need exe_wrapper in cross file
    # Use ADDITIONAL_BINARIES to add exe_wrapper to cross file
    vcpkg_configure_meson(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -Ddoc=false
            -Dgtk-examples=false
            -Dudev_rules=disabled
            -Dudev_hwdb=disabled
            -Dintrospection=false
            -Dtests=false
        ADDITIONAL_BINARIES
            "exe_wrapper = ['${CMAKE_CURRENT_LIST_DIR}/android_exe_wrapper.sh']"
    )
else()
    # macOS/OSX, Linux and other Unix-like systems
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

# For Android, we need exe_wrapper = false in cross file
# Since vcpkg_configure_meson generates and uses cross files in the same function,
# we can't modify them from portfile. The cross files are created at:
# ${CURRENT_BUILDTREES_DIR}/meson-${TARGET_TRIPLET}-{dbg,rel}.log
# We'll handle this by modifying the files after they're created but this requires
# patching vcpkg_configure_meson or using a workaround.
# Simplest workaround: Use environment variable to pass exe_wrapper, or
# modify template (affects all ports - not ideal), or
# create wrapper script that modifies cross file before meson uses it.
# For now, let's document the issue - Android build may fail without exe_wrapper
# unless we patch vcpkg_configure_meson or use a custom solution.

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

# Remove installed test binaries (they require cairo and other test dependencies)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/libexec" "${CURRENT_PACKAGES_DIR}/libexec")

vcpkg_fixup_pkgconfig()
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
