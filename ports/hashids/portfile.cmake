vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzvetkoff/hashids.c
    REF "v${VERSION}"
    SHA512 f752a95118f729eb9e9651fc5d0112271c5cb95c8cefeaef33f61611274075ba4085edca58fb14823d4665de4044eff24397b891a22c2cb196e9c1c287fae378
    HEAD_REF master
    PATCHES
        hashids.patch
)

set(EXTRA_OPTS "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # $LIBS is an environment variable that vcpkg already pre-populated with some libraries. 
    # We need to re-purpose it when passing LIBS option to make to avoid overriding the vcpkg's own list.  
    list(APPEND EXTRA_OPTS "LIBS=-lgetopt \$LIBS")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${EXTRA_OPTS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
