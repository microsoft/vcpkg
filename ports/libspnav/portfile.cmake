vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeSpacenav/libspnav
    REF libspnav-0.2.3 # v0.2.3 seems to be outdated. libspnav-0.2.3 is the same as 0.2.3 on their sourceforge
    SHA512 6c06344813ddf7e2bc7981932b4a901334de2b91d8c3abb23828869070dc73ed1c19c5bf7ff9338cc673c8f0dc7394608652afd0cdae093149c0a24460f0a8fb
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
    file(REMOVE ${WORKDIR}/lib/libspnav.so.0)
    file(RENAME ${WORKDIR}/lib/libspnav.so.0.1 ${WORKDIR}/lib/libspnav.so)
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
