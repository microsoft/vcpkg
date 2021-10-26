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

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
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
else()
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES freexl rttopo geos proj # libxml2.pc used properly by configure
        LIBS
    )
    if(VCPKG_TARGET_IS_MINGW)
        # Avoid system libs (as detected by cmake) in exported pc files
        set(SYSTEM_LIBS "")
    else()
        set(SYSTEM_LIBS "\$LIBS")
    endif()
    # libspatialite needs some targets literally
    if(VCPKG_TARGET_IS_ANDROID)
        set(TARGET_ALIAS "--target=android")
    elseif(VCPKG_TARGET_IS_MINGW)
        set(TARGET_ALIAS "--target=mingw32")
    elseif(VCPKG_TARGET_IS_OSX)
        set(TARGET_ALIAS "--target=macosx")
    else()
        set(TARGET_ALIAS "")
    endif()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            ${TARGET_ALIAS}
            "--enable-rttopo"
            "--enable-gcp"
            "--enable-geocallbacks"
            "--disable-examples"
            "--disable-minizip"
        OPTIONS_DEBUG
            "LIBS=${PKGCONFIG_LIBS_DEBUG} ${SYSTEM_LIBS}"
        OPTIONS_RELEASE
            "LIBS=${PKGCONFIG_LIBS_RELEASE} ${SYSTEM_LIBS}"
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

    if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/plugins/${PORT}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/mod_spatialite.dll" "${CURRENT_PACKAGES_DIR}/plugins/${PORT}/mod_spatialite.dll")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/mod_spatialite.dll" "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}/mod_spatialite.dll")
        endif()
    endif()
endif()

# Handle copyright
# With rttopo and ground control points enabled, the license is GPLv2+.
file(INSTALL "${SOURCE_PATH}/src/control_points/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
