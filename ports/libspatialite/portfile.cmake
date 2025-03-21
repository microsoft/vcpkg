vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${VERSION}.tar.gz"
    FILENAME "libspatialite-${VERSION}.tar.gz"
    SHA512 2745b373e31cea58623224def6090c491b58409803bb71231450dfa2cfdf3aafc3fc6f680585d55d085008f8cf362c3062ae67ffc7d80257775a22eb81ef1e57
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-makefiles.patch
        fix-linux-configure.patch
        gaiaconfig-msvc.patch
        fix-mingw.patch
        fix-utf8-source.patch
        android-builtin-iconv.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS unused
    FEATURES
        freexl          ENABLE_FREEXL
        gcp             ENABLE_GCP
        rttopo          ENABLE_RTTOPO
)

set(pkg_config_modules geos libxml-2.0 proj sqlite3 zlib)
if(ENABLE_FREEXL)
    list(APPEND pkg_config_modules freexl)
endif()
if(ENABLE_RTTOPO)
    list(APPEND pkg_config_modules rttopo)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(CL_FLAGS "")
    if(NOT ENABLE_FREEXL)
        string(APPEND CL_FLAGS " /DOMIT_FREEXL")
    endif()
    if(ENABLE_GCP)
        string(APPEND CL_FLAGS " /DENABLE_GCP")
    endif()
    if(ENABLE_RTTOPO)
        string(APPEND CL_FLAGS " /DENABLE_RTTOPO")
    endif()

    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES --msvc-syntax ${pkg_config_modules}
        LIBS
        CFLAGS
    )
    
    set(CL_FLAGS_RELEASE "${CL_FLAGS} ${PKGCONFIG_CFLAGS_RELEASE}")
    set(CL_FLAGS_DEBUG "${CL_FLAGS} ${PKGCONFIG_CFLAGS_DEBUG}")

    # vcpkg_build_nmake doesn't supply cmake's implicit link libraries
    if(PKGCONFIG_LIBS_DEBUG MATCHES "libcrypto")
        string(APPEND PKGCONFIG_LIBS_DEBUG " user32.lib")
    endif()
    if(PKGCONFIG_LIBS_RELEASE MATCHES "libcrypto")
        string(APPEND PKGCONFIG_LIBS_RELEASE " user32.lib")
    endif()

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

    if(ENABLE_RTTOPO)
        list(APPEND pkg_config_modules rttopo)
    endif()
    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PREFER_JOM
        CL_LANGUAGE C
        OPTIONS_RELEASE
            "CL_FLAGS=${CL_FLAGS_RELEASE}"
            "INST_DIR=${INST_DIR}"
            "LIBS_ALL=${LIBS_ALL_RELEASE}"
        OPTIONS_DEBUG
            "CL_FLAGS=${CL_FLAGS_DEBUG}"
            "INST_DIR=${INST_DIR}\\debug"
            "LIBS_ALL=${LIBS_ALL_DEBUG}"
            "LINK_FLAGS=/debug"
    )

    vcpkg_copy_pdbs()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib")
        if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib")
        endif()
    else()
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/spatialite.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib" "${CURRENT_PACKAGES_DIR}/lib/spatialite.lib")
        if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib")
        endif()
    endif()

    set(infile "${SOURCE_PATH}/spatialite.pc.in")
    set(libdir [[${prefix}/lib]])
    set(exec_prefix [[${prefix}]])
    list(JOIN pkg_config_modules " " requires_private)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(includedir [[${prefix}/include]])
        set(outfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/spatialite.pc")
        configure_file("${infile}" "${outfile}" @ONLY)
        vcpkg_replace_string("${outfile}" "Libs:" "Requires.private: ${requires_private}\nLibs.private: -liconv -lcharset\nLibs:")
        vcpkg_replace_string("${outfile}" "  -lm" " ")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(includedir [[${prefix}/../include]])
        set(outfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/spatialite.pc")
        configure_file("${infile}" "${outfile}" @ONLY)
        vcpkg_replace_string("${outfile}" "Libs:" "Requires.private: ${requires_private}\nLibs.private: -liconv -lcharset\nLibs:")
        vcpkg_replace_string("${outfile}" "  -lm" " ")
    endif()
else()
    if(ENABLE_FREEXL)
        set(FREEXL_OPTION "--enable-freexl")
    else()
        set(FREEXL_OPTION "--disable-freexl")
    endif()
    if(ENABLE_GCP)
        set(GCP_OPTION "--enable-gcp")
    else()
        set(GCP_OPTION "--disable-gcp")
    endif()
    if(ENABLE_GEOCALLBACKS)
        set(GEOCALLBACKS_OPTION "--enable-geocallbacks")
    else()
        set(GEOCALLBACKS_OPTION "--disable-geocallbacks")
    endif()
    if(ENABLE_RTTOPO)
        set(RTTOPO_OPTION "--enable-rttopo")
    else()
        set(RTTOPO_OPTION "--disable-rttopo")
    endif()
    list(REMOVE_ITEM pkg_config_modules libxml2) # handled properly by configure
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES ${pkg_config_modules} 
        LIBS
    )
    if(VCPKG_TARGET_IS_MINGW)
        # Avoid system libs (as detected by cmake) in exported pc files
        set(SYSTEM_LIBS "")
    elseif(VCPKG_TARGET_IS_ANDROID)
        set(SYSTEM_LIBS "\$LIBS -llog")
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
        DETERMINE_BUILD_TRIPLET
        OPTIONS
            ${TARGET_ALIAS}
            ${FREEXL_OPTION}
            ${GCP_OPTION}
            ${RTTOPO_OPTION}
            "--disable-examples"
            "--disable-minizip"
            "cross_compiling=yes" # avoid conftest rpath trouble
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
        vcpkg_replace_string("${makefile}" " -I$(top_builddir)/./src/headers/spatialite" " -I$(top_builddir)/./src/headers" IGNORE_UNCHANGED)
    endforeach()

    vcpkg_install_make()

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

vcpkg_fixup_pkgconfig()

# Handle copyright
set(outfile "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
if(NOT ENABLE_GCP AND NOT ENABLE_RTTOPO)
    file(READ "${SOURCE_PATH}/COPYING" mpl)
    file(WRITE "${outfile}"
        "SpatiaLite[${FEATURES}] is licensed under the MPL tri-license terms;\n"
        "you are free to choose the best-fit license between:\n"
        "- the MPL 1.1\n"
        "- the GPL v2.0 or any subsequent version\n"
        "- the LGPL v2.1 or any subsequent version.\n\n"
        "# MPL 1.1 (from COPYING)\n\n"
        "${mpl}\n"
    )
else()
    file(WRITE "${outfile}"
        "SpatiaLite[${FEATURES}] is licensed under:\n"
        "the GPL v2.0 or any subsequent version.\n\n"
    )
endif()
file(READ "${SOURCE_PATH}/src/control_points/COPYING" gpl)
file(APPEND "${outfile}"
    "# GPL v2.0 (from src/control_points/COPYING)\n\n"
    "${gpl}\n"
)
