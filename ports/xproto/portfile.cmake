if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(PATCHES 
            vcxserver-xw32defs.patch
            windows-long64.patch
            windows-io.patch
            windows_mean_and_lean.patch
            windows-none.patch
            windows-include-guards.patch
        )
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO proto/xorgproto
    REF 57acac1d4c7967f4661fb1c9f86f48f34a46c48d # 2021.5
    SHA512 5d2b6096e7f6ec6a3414f4370da583f6660fbd287474e8b4cd3e51ccc35514181352d3b0b9cd4b8d6e30de7b54f4ce01a9fbf17be75cf8de18aa28e9f774b8c4
    HEAD_REF master
    PATCHES 
        upstream-1.patch
        ${PATCHES}
)

vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}"
                      OPTIONS "-Dlegacy=true")
vcpkg_install_meson()

# To make CMake consumption easier.
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/")
 file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/")
 file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/pkgconfig/")
 file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/")
 file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()

vcpkg_fixup_pkgconfig(SKIP_CHECK) # pc files requiring Xau Xt xt SM ICE X11 xcb Xdmcp are installed before they can be used.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(GLOB_RECURSE _files "${SOURCE_PATH}/COPYING*")
file(INSTALL ${_files} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST ${_files})
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "")
endif()
