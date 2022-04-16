vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeSpacenav/libspnav
    REF v1.0
    SHA512 ae36ea51dbca7d5ba31d82ffaa46bad2bd877f5f7c077d2e711747427f6d60a000ab0c827ae6523ba6a275dbad205eea8c20520fe2575a6fa6b554ea8b5e0eaa
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG "--enable-debug"
    OPTIONS_RELEASE "--disable-debug"
)

vcpkg_install_make()

macro(CLEANUP WHERE)
    set(WORKDIR "${CURRENT_PACKAGES_DIR}/${WHERE}")
    if ("${WHERE}" STREQUAL "debug")
        file(REMOVE_RECURSE "${WORKDIR}/include")
    endif ()
    file(REMOVE "${WORKDIR}/lib/libspnav.so")
    file(REMOVE "${WORKDIR}/lib/libspnav.so.0")
    file(RENAME "${WORKDIR}/lib/libspnav.so.0.1" "${WORKDIR}/lib/libspnav.so")
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE "${WORKDIR}/lib/libspnav.so")
    else ()
        file(REMOVE "${WORKDIR}/lib/libspnav.a")
    endif ()
endmacro()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    cleanup("")
endif ()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    cleanup("debug")
endif ()

file(INSTALL "${SOURCE_PATH}/README"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
