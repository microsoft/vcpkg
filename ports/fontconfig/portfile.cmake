set(FONTCONFIG_VERSION 2.14.1)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fontconfig/fontconfig
    REF ${FONTCONFIG_VERSION}
    SHA512 39d25e2fde5085cf66230e18621c1b7ab33935c78771dcc9d6b9e514ddd39af53fcdb0d89a8c7f582d476f431ccf61adde427509256c49cd9d09d249d2d736f7
    HEAD_REF master
    PATCHES
        no-etc-symlinks.patch
        libgetopt.patch
        fix-mingw-gperf-fallback.patch
        fix-preprocessor-clang-cl.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddoc=disabled
        -Dcache-build=disabled
        -Dtests=disabled
)
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()
#Fix missing libintl static dependency
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/fontconfig.pc" "-liconv" "-liconv -lintl")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/fontconfig.pc" "-liconv" "-liconv -lintl")
endif()
vcpkg_fixup_pkgconfig()

# Fix paths in debug pc file.
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/fontconfig.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "/etc" "/../etc" _contents "${_contents}")
    string(REPLACE "/var" "/../var" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

# Make path to cache in fonts.conf relative
set(_file "${CURRENT_PACKAGES_DIR}/etc/fonts/fonts.conf")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "${CURRENT_PACKAGES_DIR}/var/cache/fontconfig" "./../../var/cache/fontconfig")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/var"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/etc")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(DEFINE_FC_PUBLIC "#define FcPublic __declspec(dllimport)")
    else()
        set(DEFINE_FC_PUBLIC "#define FcPublic __attribute__((visibility(\"default\")))")
    endif()
    foreach(HEADER IN ITEMS fcfreetype.h fontconfig.h)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER}"
            "#define FcPublic"
            "${DEFINE_FC_PUBLIC}"
        )
    endforeach()
endif()

vcpkg_copy_tools(
    TOOL_NAMES fc-match fc-cat fc-list fc-pattern fc-query fc-scan fc-cache fc-validate fc-conflist
    AUTO_CLEAN
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
