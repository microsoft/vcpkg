vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeSpacenav/libspnav
    REF "v${VERSION}"
    SHA512 94770d9449dd02ade041d3589bcae7664fa990c4a4feca7b2b1e6542b65aa7073305595310b9e639f10716cf15aaad913e57496fb79bdd4dba5bf703ec8299ab
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
