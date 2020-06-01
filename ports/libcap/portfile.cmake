vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.kernel.org/pub/scm/libs/libcap/libcap.git/
    REF 1f7f77c32e51e89f22ae271bae12b9103f28af2b
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    COPY_SOURCE
    SKIP_CONFIGURE )

vcpkg_install_make(CONFIG_DEPENDENT_DESTDIR)


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/usr)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/sbin)

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib64")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib64" "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
file(RENAME "${CURRENT_PACKAGES_DIR}/lib64" "${CURRENT_PACKAGES_DIR}/lib")

file(RENAME "${CURRENT_PACKAGES_DIR}/usr/include" "${CURRENT_PACKAGES_DIR}/include")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/man/")
file(RENAME "${CURRENT_PACKAGES_DIR}/usr/share/man/" "${CURRENT_PACKAGES_DIR}/share/${PORT}/man/")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")
file(RENAME "${CURRENT_PACKAGES_DIR}/sbin/" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sbin/")

set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcap.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "/lib64" "\${prefix}/lib" _contents "${_contents}")
    string(REPLACE "/usr" "\${prefix}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpsx.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "/lib64" "\${prefix}/lib" _contents "${_contents}")
    string(REPLACE "/usr" "\${prefix}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcap.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "/lib64" "\${prefix}/lib" _contents "${_contents}")
    string(REPLACE "/usr" "\${prefix}" _contents "${_contents}")
    string(REPLACE "/include" "/../include" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpsx.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "/lib64" "\${prefix}/lib" _contents "${_contents}")
    string(REPLACE "/usr" "\${prefix}" _contents "${_contents}")
    string(REPLACE "/include" "/../include" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread IGNORE_FLAGS "-Wl,-wrap,pthread_create")


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/usr)
# # Handle copyright
file(INSTALL "${SOURCE_PATH}/License" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
