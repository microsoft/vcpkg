vcpkg_fail_port_install(ON_TARGET "windows" "uwp" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeSpacenav/libspnav
    REF v0.2.3
    SHA512 fe01a8e8496aa5648553ad8a769aa15a4de127e3cf0a1d2c56353bf9757fe025383d64a07709c33199f658aa00adcb1fa754891f7de2250610a56664bc107c45
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG "--enable-debug"
    OPTIONS_RELEASE "--disable-debug"
)

vcpkg_install_make()

macro(CLEANUP WHERE)
    set(WORKDIR ${CURRENT_PACKAGES_DIR}/${WHERE})
    if ("${WHERE}" STREQUAL "debug")
        file(REMOVE_RECURSE ${WORKDIR}/include)
    endif ()
    file(REMOVE ${WORKDIR}/lib/libspnav.so)
    file(REMOVE ${WORKDIR}/lib/libspnav.so.)
    file(RENAME ${WORKDIR}/lib/libspnav.so.. ${WORKDIR}/lib/libspnav.so)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE ${WORKDIR}/lib/libspnav.so)
    else ()
        file(REMOVE ${WORKDIR}/lib/libspnav.a)
    endif ()
endmacro()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    cleanup("")
endif ()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    cleanup("debug")
endif ()

file(INSTALL ${SOURCE_PATH}/README
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)