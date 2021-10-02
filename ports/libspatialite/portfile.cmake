set(LIBSPATIALITE_VERSION_STR "5.0.1")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    FILENAME "libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    SHA512 c2552994bc30d69d1e80aa274760f048cd384f71e8350a1e48a47cb8222ba71a1554a69c6534eedde9a09dc582c39c089967bcc1c57bf158cc91a3e7b1840ddf
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-makefiles.patch
        fix-linux-configure.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES --msvc-syntax freexl rttopo geos libxml-2.0 proj sqlite3 zlib
        LIBS
    )
    string(JOIN " " LIBS_ALL_DEBUG
        "/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
        "${PKGCONFIG_LIBS_DEBUG}"
        iconv.lib charset.lib
    )
    string(JOIN " " LIBS_ALL_RELEASE
        "/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
        "${PKGCONFIG_LIBS_RELEASE}"
        iconv.lib charset.lib
    )

    string(REPLACE "/" "\\\\" INST_DIR "${CURRENT_PACKAGES_DIR}")

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS_RELEASE
            "INST_DIR=${INST_DIR}"
            "LIBS_ALL=${LIBS_ALL_RELEASE}"
        OPTIONS_DEBUG
            "INST_DIR=${INST_DIR}\\debug"
            "LIBS_ALL=${LIBS_ALL_DEBUG}"
            "LINK_FLAGS=/debug"
    )

    vcpkg_copy_pdbs()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib")
    else()
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/spatialite.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib" "${CURRENT_PACKAGES_DIR}/lib/spatialite.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib")
    endif()
else() # Build in UNIX
    if(VCPKG_TARGET_IS_LINUX)
        set(STDLIB stdc++)
    else()
        set(STDLIB c++)
    endif()
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
      SET(EXTRALIBS "-lpthread")
    endif()
    list(APPEND OPTIONS_RELEASE
        "LIBXML2_LIBS=-lxml2 -llzma"
        "GEOS_LDFLAGS=-lgeos_c -lgeos -l${STDLIB}"
    )
    list(APPEND OPTIONS_DEBUG
        "LIBXML2_LIBS=-lxml2 -llzmad"
        "GEOS_LDFLAGS=-lgeos_cd -lgeosd -l${STDLIB}"
    )

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            "LIBS=${EXTRALIBS} -ldl -lm -l${STDLIB}"
            "LIBXML2_CFLAGS=-I${CURRENT_INSTALLED_DIR}/include"
            "--enable-rttopo"
            "--enable-gcp"
            "--enable-geocallbacks"
            "--disable-examples"
            "--disable-minizip"
        OPTIONS_DEBUG
            ${OPTIONS_DEBUG}
        OPTIONS_RELEASE
            ${OPTIONS_RELEASE}
    )

    # automake adds the basedir of the generated config to `DEFAULT_INCLUDES`,
    # but libspatialite uses `#include <spatialite/gaiaconfig.h>`.
    file(GLOB_RECURSE makefiles
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Makefile"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Makefile"
    )
    foreach(makefile IN LISTS makefiles)
        vcpkg_replace_string("${makefile}" " -I$(top_builddir)/./src/headers/spatialite" " -I$(top_builddir)/./src/headers")
    endforeach()

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
# With rttopo and ground control points enabled, the license is GPLv2+.
file(INSTALL "${SOURCE_PATH}/src/control_points/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
