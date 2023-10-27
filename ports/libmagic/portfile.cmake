set(PATCHES
    "0001-Use-pcre2.patch"
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES
        ${PATCHES}
        "0003-Fix-WIN32-macro-checks.patch"
        "0004-Typedef-POSIX-types-on-Windows.patch"
        "0005-Include-dirent.h-for-S_ISREG-and-S_ISDIR.patch"
        "0006-Remove-Wrap-POSIX-headers.patch"
        "0007-Substitute-unistd-macros-for-MSVC.patch"
        "0008-Add-FILENO-defines.patch"
        "0010-Properly-check-for-the-presence-of-bitmasks.patch"
        "0011-Remove-pipe-related-functions-in-funcs.c.patch"
        "0015-MSYS2-Remove-ioctl-call.patch"
        "0016-Fix-file_famagic-function.patch"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO file/file
    REF FILE5_45
    SHA512 fdd4c5d13d5ea1d25686c76d8ebc3252c54040c4871e3f0f623c4548b3841795d4e36050292a9453eedf0fbf932573890e9d6ac9fa63ccf577215598ae84b9ea
    HEAD_REF master
    PATCHES ${PATCHES}
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-libmagic-config.cmake.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/magic.def" DESTINATION "${SOURCE_PATH}/src")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h" DESTINATION "${SOURCE_PATH}/src")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES file AUTO_CLEAN)
vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/unofficial-libmagic
    PACKAGE_NAME unofficial-libmagic)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/man5")

if(NOT VCPKG_CROSSCOMPILING)
    # Generate magic.mgc
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/file" -C -m magic
        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/misc"
        LOGNAME file-generate-${HOST_TRIPLET}
    )
endif()
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/misc/magic")

set(UNOFFICIAL_PORT unofficial-${PORT})

# Handle copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
