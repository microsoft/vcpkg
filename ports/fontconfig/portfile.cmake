vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fontconfig/fontconfig
    REF ${VERSION}
    SHA512 b6cbb4ad7db224dabfb8a96c1d0743bab5bbe8f403e49d9b9a44effd161fd97062a2f7205a700308a1f805655038538ba2fb1b65169faa2d69ea88e477230849
    HEAD_REF master
    PATCHES
        no-etc-symlinks.patch
        libgetopt.patch
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

# https://www.freedesktop.org/software/fontconfig/fontconfig-user.html
# Adding OPTIONS for e.g. baseconfig-dir etc. won't work since meson will try to install into those dirs!
# Since adding OPTIONS does not work use a replacement in the generated config.h instead
set(replacement "")
if(VCPKG_TARGET_IS_WINDOWS)
    set(replacement "**invalid-fontconfig-dir-do-not-use**")
endif()
set(configfile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.h")
vcpkg_replace_string("${configfile}" "${CURRENT_PACKAGES_DIR}" "${replacement}")
vcpkg_replace_string("${configfile}" "#define FC_TEMPLATEDIR \"/share/fontconfig/conf.avail\"" "#define FC_TEMPLATEDIR \"/usr/share/fontconfig/conf.avail\"" IGNORE_UNCHANGED)
if(NOT VCPKG_BUILD_TYPE)
    set(configfile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.h")
    vcpkg_replace_string("${configfile}" "${CURRENT_PACKAGES_DIR}/debug" "${replacement}")
    vcpkg_replace_string("${configfile}" "#define FC_TEMPLATEDIR \"/share/fontconfig/conf.avail\"" "#define FC_TEMPLATEDIR \"/usr/share/fontconfig/conf.avail\"" IGNORE_UNCHANGED)
endif()

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()
#Fix missing libintl static dependency
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/fontconfig.pc" "-liconv" "-liconv -lintl" IGNORE_UNCHANGED)
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/fontconfig.pc" "-liconv" "-liconv -lintl" IGNORE_UNCHANGED)
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
    vcpkg_replace_string("${_file}" "${CURRENT_PACKAGES_DIR}/var/cache/fontconfig" "./../../var/cache/fontconfig" IGNORE_UNCHANGED)
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
