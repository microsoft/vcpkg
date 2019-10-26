include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libical/libical
    REF v3.0.6
    SHA512 624b70b54da1ff30085fd16bf136496f179088dd089a3bea7e9cfcf3ad07588907d99ff07782b33f5fdfd4fbfc0bae9daa42bb965380b28bf1c9ce4481b698cb
)

#Perl is required by the buildsystem.
vcpkg_find_acquire_program(PERL)

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
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/LibICal
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libical/cmake
    FILES_MATCHING PATTERN "*.cmake" )
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libical)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libical/LICENSE.txt)
file(COPY ${SOURCE_PATH}/LICENSE.LGPL21.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libical)
file(COPY ${SOURCE_PATH}/LICENSE.MPL2.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libical)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libical/COPYING ${CURRENT_PACKAGES_DIR}/share/libical/copyright)
