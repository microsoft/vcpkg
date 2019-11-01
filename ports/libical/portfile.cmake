vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libical/libical
    REF 0595c7d45ef5e75705f2d80e03e5310d9f78438c #v3.0.6 tag
    SHA512 611dcb28500b9db23262926e6869f3e3920ece585f059be4e09c356d949014770b7f1f95d1e3e75e770b6c38f91c4ae8a014df8dc86d5191f12bc5d9b0549216
)

#Perl is required by the buildsystem.
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

set(BUILD_ICAL_GLIB OFF)
#TODO need pkgconfig, glib and libxml2 to build libical-glib
#if("glib" IN_LIST FEATURES AND "libxml2" IN_LIST FEATURES)
#set(BUILD_ICAL_GLIB ON)
#endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSHARED_ONLY=False
        -DSTATIC_ONLY=False
        -DUSE_BUILTIN_TZDATA=True
        -DICAL_BUILD_DOCS=False
        -DICAL_GLIB=${BUILD_ICAL_GLIB}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibIcal TARGET_PATH share/LibIcal)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
