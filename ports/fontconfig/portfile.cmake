set(FONTCONFIG_VERSION 2.13.94)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fontconfig/fontconfig
    REF ${FONTCONFIG_VERSION}
    SHA512 815f999146970c7f0e6c15a21f218d4b3f75b26d4ef14d36711bc0a1de19e59cc62d6a2c53993dd38b963ae30820c4db29f103380d5001886d55b6a7df361154
    HEAD_REF master
    PATCHES
        no-etc-symlinks.patch
)

vcpkg_find_acquire_program(GPERF)
get_filename_component(GPERF_PATH ${GPERF} DIRECTORY)
vcpkg_add_to_path(${GPERF_PATH})

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Ddoc=disabled
)
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()
#Fix missing libintl static dependency
if(NOT VCPKG_TARGET_IS_MINGW AND VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(DEFINE_FC_PUBLIC "#define FcPublic __declspec(dllimport)")
    else()
        set(DEFINE_FC_PUBLIC "#define FcPublic __attribute__((visibility(\"default\")))")
    endif()
    foreach(HEADER fcfreetype.h fontconfig.h)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER}"
            "#define FcPublic"
            "${DEFINE_FC_PUBLIC}"
        )
    endforeach()
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)


# Build the fontconfig cache
if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_CROSSCOMPILING)
    set(ENV{FONTCONFIG_PATH} "${CURRENT_PACKAGES_DIR}/etc/fonts")
    set(ENV{FONTCONFIG_FILE} "${CURRENT_PACKAGES_DIR}/etc/fonts/fonts.conf")
    vcpkg_execute_required_process(COMMAND "${CURRENT_PACKAGES_DIR}/bin/fc-cache${VCPKG_TARGET_EXECUTABLE_SUFFIX}" --verbose
                                   WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin"
                                   LOGNAME fc-cache-${TARGET_TRIPLET})
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # Unnecessary make rule creating the fontconfig cache dir on windows.
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}LOCAL_APPDATA_FONTCONFIG_CACHE")
endif()

if(NOT VCPKG_TARGET_IS_LINUX)
    set(VCPKG_TARGET_IS_LINUX 0) # To not leave empty AND statements in the wrapper
endif()
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

vcpkg_copy_tools(
    TOOL_NAMES fc-match fc-cat fc-list fc-pattern fc-query fc-scan fc-cache fc-validate fc-conflist
    AUTO_CLEAN
)
