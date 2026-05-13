# zvbi has no __declspec(dllexport) annotations, so static only on Windows
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zapping-vbi/zvbi
    REF v0.2.44
    SHA512 74b7d44faf42f919ebd3ccb69f8567f56909075d3acf4a3b4dfcbdf85489492f27d8a04173e0010f59706356e4078cd10911945f87e2596de2b897672d1e55cb
    HEAD_REF main
    PATCHES
        patches/001-msvc-compat.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    # Copy our CMake build file into the source tree
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/src")
    # config.h   - autotools config (HAVE_*, ssize_t, mode_t, S_IRUSR, SSIZE_MAX, etc.)
    # site_def.h - empty build-config placeholder
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h"   DESTINATION "${SOURCE_PATH}/src")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/site_def.h" DESTINATION "${SOURCE_PATH}/src")
else()
    # The MSVC-compat patch creates Windows-only shim headers that shadow POSIX equivalents.
    # Remove them so the autotools build uses the real system headers.
    file(REMOVE "${SOURCE_PATH}/src/unistd.h")
    file(REMOVE "${SOURCE_PATH}/src/strings.h")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/sys")
endif()


if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}/src"
    )
    vcpkg_cmake_install()
    vcpkg_copy_pdbs()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
else()
    vcpkg_find_acquire_program(PKGCONFIG)
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            --disable-static
            --enable-shared
    )
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.md")
