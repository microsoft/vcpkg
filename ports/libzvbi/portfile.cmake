# zvbi has no __declspec(dllexport) annotations, so static only on Windows.
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
        patches/002-disable-gettext-autopoint.patch
        patches/003-msvc-compat-additional.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    # The MSVC-compat patch creates Windows-only shim headers that shadow POSIX equivalents.
    # Remove them so the autotools build uses the real system headers on Unix/macOS.
    file(REMOVE "${SOURCE_PATH}/src/unistd.h")
    file(REMOVE "${SOURCE_PATH}/src/strings.h")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/sys")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # zvbi uses GCC's __inline__ extension everywhere; map it to C99 inline for MSVC.
    string(APPEND VCPKG_C_FLAGS " -D__inline__=inline")
    string(APPEND VCPKG_CXX_FLAGS " -D__inline__=inline")
    # contrib/ntsc-cc.c uses POSIX-only headers (unistd.h, etc.) that are not available with MSVC.
    # Remove the contrib directory so autotools skips it (there is no configure flag to disable it).
    file(REMOVE_RECURSE "${SOURCE_PATH}/contrib")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --disable-nls
        --disable-examples
        --disable-tests
    OPTIONS_WINDOWS
        # pthreads-win32 provides pid_t via sched.h; bypass autoconf's AC_TYPE_PID_T which
        # adds '#define pid_t int' to config.h and clashes with the typedef in sched.h
        ac_cv_type_pid_t=yes
)

# Fix libtool quoting: configure writes lt_ar_flags=-machine:x64 -nologo cr
# without quotes, so bash interprets '-nologo cr' as a command
if(VCPKG_TARGET_IS_WINDOWS)
    foreach(_buildtype IN ITEMS "dbg" "rel")
        set(_ltfile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_buildtype}/libtool")
        if(EXISTS "${_ltfile}")
            file(READ "${_ltfile}" _ltcontent)
            string(REGEX REPLACE
                "lt_ar_flags=([^\"\n][^\n]*[^ \n])"
                [[lt_ar_flags="\1"]]
                _ltcontent "${_ltcontent}")
            file(WRITE "${_ltfile}" "${_ltcontent}")
        endif()
    endforeach()
endif()

vcpkg_make_install()

# MSVC links math via the CRT — remove the Unix-only -lm from pkgconfig.
if(VCPKG_TARGET_IS_WINDOWS)
    foreach(_pc_file IN ITEMS
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zvbi-0.2.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zvbi-0.2.pc")
        if(EXISTS "${_pc_file}")
            file(READ "${_pc_file}" _pc_content)
            string(REPLACE " -lm" "" _pc_content "${_pc_content}")
            file(WRITE "${_pc_file}" "${_pc_content}")
        endif()
    endforeach()
endif()

vcpkg_fixup_pkgconfig()

# Remove tools (not needed; avoids RPATH/headerpad issues on macOS).
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.md")
