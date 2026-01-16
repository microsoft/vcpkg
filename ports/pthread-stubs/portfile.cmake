set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL "https://gitlab.freedesktop.org/xorg"
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "lib/pthread-stubs"
    REF "libpthread-stubs-${VERSION}"
    SHA512 b2429828f51cc6c9bbb9879c9933ff747354574626ff8fcfbec22c41ded1e9bdf4049715485f580e72c561dfd54d48d731c1f6ae9fff229976890361e3276f2e
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pthread-stubs.pc")
file(READ "${_file}" _contents)
string(REPLACE "Cflags: -pthread" "Cflags: " _contents "${_contents}")
if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/pthreadVC3.lib")
    string(REPLACE "Libs: -pthread" "Libs: -lpthreadVC3" _contents "${_contents}")
endif()
if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/pthreadGC3.lib")
    string(REPLACE "Libs: -pthread" "Libs: -lpthreadGC3" _contents "${_contents}")
endif()
file(WRITE "${_file}" "${_contents}")

if(NOT VCPKG_BUILD_TYPE)
    set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/pthread-stubs.pc")
    file(READ "${_file}" _contents)
    string(REPLACE "Cflags: -pthread" "Cflags: " _contents "${_contents}")
    if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/pthreadVC3.lib")
        string(REPLACE "Libs: -pthread" "Libs: -lpthreadVC3" _contents "${_contents}")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/pthreadGC3.lib")
        string(REPLACE "Libs: -pthread" "Libs: -lpthreadGC3" _contents "${_contents}")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/pthreadVC3d.lib")
        string(REPLACE "Libs: -pthread" "Libs: -lpthreadVC3d" _contents "${_contents}")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/pthreadGC3d.lib")
        string(REPLACE "Libs: -pthread" "Libs: -lpthreadGC3d" _contents "${_contents}")
    endif()
    file(WRITE "${_file}" "${_contents}")
endif()
