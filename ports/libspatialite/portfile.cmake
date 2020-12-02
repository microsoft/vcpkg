set(LIBSPATIALITE_VERSION_STR "4.3.0a")
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    FILENAME "libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    SHA512 adfd63e8dde0f370b07e4e7bb557647d2bfb5549205b60bdcaaca69ff81298a3d885e7c1ca515ef56dd0aca152ae940df8b5dbcb65bb61ae0a9337499895c3c0
)

if (VCPKG_TARGET_IS_WINDOWS)
    find_program(NMAKE nmake)

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        PATCHES
            fix-makefiles.patch
            fix-sources.patch
            fix-latin-literals.patch
    )

    # fix most of the problems when spacebar is in the path
    set(CURRENT_INSTALLED_DIR "\"${CURRENT_INSTALLED_DIR}\"")

    if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(CL_FLAGS_DBG "/MDd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
        set(CL_FLAGS_REL "/MD /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
        set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib")
        set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib")
        set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib")
        set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib")
    else()
        set(CL_FLAGS_DBG "/MTd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
        set(CL_FLAGS_REL "/MT /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
        set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib ${CURRENT_INSTALLED_DIR}/lib/geos.lib")
        set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/geosd.lib")
        set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/lib/lzma.lib ws2_32.lib")
        set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/debug/lib/lzmad.lib ws2_32.lib")
    endif()

    set(LIBS_ALL_DBG
        "${CURRENT_INSTALLED_DIR}/debug/lib/iconv.lib \
        ${CURRENT_INSTALLED_DIR}/debug/lib/charset.lib \
        ${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib \
        ${CURRENT_INSTALLED_DIR}/debug/lib/freexl.lib \
        ${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib \
        ${LIBXML2_LIBS_DBG} \
        ${GEOS_LIBS_DBG} \
        ${CURRENT_INSTALLED_DIR}/debug/lib/proj_d.lib ole32.lib shell32.lib"
       )
    set(LIBS_ALL_REL
        "${CURRENT_INSTALLED_DIR}/lib/iconv.lib \
        ${CURRENT_INSTALLED_DIR}/lib/charset.lib \
        ${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib \
        ${CURRENT_INSTALLED_DIR}/lib/freexl.lib \
        ${CURRENT_INSTALLED_DIR}/lib/zlib.lib \
        ${LIBXML2_LIBS_REL} \
        ${GEOS_LIBS_REL} \
        ${CURRENT_INSTALLED_DIR}/lib/proj.lib ole32.lib shell32.lib"
       )

    ################
    # Debug build
    ################
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${TARGET_TRIPLET}-dbg")

        file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)

        vcpkg_execute_required_process(
            COMMAND ${NMAKE} -f makefile.vc clean install
            "INST_DIR=\"${INST_DIR_DBG}\"" INSTALLED_ROOT=${CURRENT_INSTALLED_DIR} "LINK_FLAGS=/debug" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${LIBS_ALL_DBG}"
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME nmake-build-${TARGET_TRIPLET}-debug
        )
        message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
        vcpkg_copy_pdbs()
    endif()

    ################
    # Release build
    ################
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${TARGET_TRIPLET}-rel")

        file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
        vcpkg_execute_required_process(
            COMMAND ${NMAKE} -f makefile.vc clean install
            "INST_DIR=\"${INST_DIR_REL}\"" INSTALLED_ROOT=${CURRENT_INSTALLED_DIR} "LINK_FLAGS=" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${LIBS_ALL_REL}"
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME nmake-build-${TARGET_TRIPLET}-release
        )
        message(STATUS "Building ${TARGET_TRIPLET}-rel done")
    endif()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libspatialite RENAME copyright)

    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
      file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
      file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
      file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib)
      file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib)
    else()
      file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/spatialite.lib)
      file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib)
      if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib ${CURRENT_PACKAGES_DIR}/lib/spatialite.lib)
      endif()
      if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib)
      endif()
    endif()

    message(STATUS "Packaging ${TARGET_TRIPLET} done")
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  # Check build system first
  find_program(MAKE make)
  if (NOT MAKE)
      message(FATAL_ERROR "MAKE not found")
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    ################
    # Release build
    ################    
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH_RELEASE
        ARCHIVE ${ARCHIVE}
        REF  release
        PATCHES
            fix-sources.patch
            fix-latin-literals.patch
            fix-linux-configure.patch
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    set(OUT_PATH_RELEASE ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-release)
    file(REMOVE_RECURSE ${OUT_PATH_RELEASE})
    file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
    set(prefix ${CURRENT_INSTALLED_DIR})
    set(exec_prefix ${prefix}/bin)
    set(includedir ${prefix}/include)
    set(libdir ${prefix}/lib)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/geos-config.in
                   ${SOURCE_PATH_RELEASE}/geos-config @ONLY)
    vcpkg_execute_required_process(
      COMMAND chmod -R 777 ${SOURCE_PATH_RELEASE}/geos-config
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME config-${TARGET_TRIPLET}-rel
    )
    vcpkg_execute_required_process(
      COMMAND "${SOURCE_PATH_RELEASE}/configure" --prefix=${OUT_PATH_RELEASE} "CFLAGS=-I${includedir} ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE} -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H" "LDFLAGS=-L${libdir}" "LIBS=-lpthread -ldl -lproj" "--with-geosconfig=${SOURCE_PATH_RELEASE}/geos-config" "LIBXML2_LIBS=-lxml2 -llzma" "LIBXML2_CFLAGS=${includedir}"
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME config-${TARGET_TRIPLET}-rel
    )

    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_build_process(
      COMMAND make -j ${VCPKG_CONCURRENCY}
      NO_PARALLEL_COMMAND make
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME make-build-${TARGET_TRIPLET}-release
    )

    message(STATUS "Installing ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
      COMMAND make install
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME make-install-${TARGET_TRIPLET}-release
    )

    set(VERSION ${LIBSPATIALITE_VERSION_STR})
    configure_file(${SOURCE_PATH_RELEASE}/spatialite.pc.in
                   ${OUT_PATH_RELEASE}/lib/pkgconfig/spatialite.pc @ONLY)
    file(COPY ${OUT_PATH_RELEASE}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
    file(COPY ${OUT_PATH_RELEASE}/include DESTINATION ${CURRENT_PACKAGES_DIR})
    file(INSTALL ${SOURCE_PATH_RELEASE}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libspatialite RENAME copyright)
    message(STATUS "Installing ${TARGET_TRIPLET}-rel done")
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    ################
    # Debug build
    ################    
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH_DEBUG
        ARCHIVE ${ARCHIVE}
        REF  debug
        PATCHES
            fix-sources.patch
            fix-latin-literals.patch
            fix-configure-debug.patch
            fix-linux-configure.patch
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    set(OUT_PATH_DEBUG ${SOURCE_PATH_DEBUG}/../../make-build-${TARGET_TRIPLET}-debug)
    file(REMOVE_RECURSE ${OUT_PATH_DEBUG})
    file(MAKE_DIRECTORY ${OUT_PATH_DEBUG})
    set(prefix ${CURRENT_INSTALLED_DIR})
    set(exec_prefix ${prefix}/debug/bin)
    set(includedir ${prefix}/include)
    set(libdir ${prefix}/debug/lib)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/geos-config-debug.in
                   ${SOURCE_PATH_DEBUG}/geos-config @ONLY)
    vcpkg_execute_required_process(
      COMMAND chmod -R 777 ${SOURCE_PATH_DEBUG}/geos-config
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME config-${TARGET_TRIPLET}-debug
    )
    vcpkg_execute_required_process(
      COMMAND "${SOURCE_PATH_DEBUG}/configure" --prefix=${OUT_PATH_DEBUG}  "CFLAGS=-I${includedir} ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG} -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H" "LDFLAGS=-L${libdir}" "LIBS=-lpthread -ldl -lproj" "--with-geosconfig=${SOURCE_PATH_DEBUG}/geos-config" "LIBXML2_LIBS=-lxml2 -llzmad" "LIBXML2_CFLAGS=${includedir}"
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME config-${TARGET_TRIPLET}-debug
    )

    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_build_process(
      COMMAND make -j ${VCPKG_CONCURRENCY}
      NO_PARALLEL_COMMAND make
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME make-build-${TARGET_TRIPLET}-debug
    )

    message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
      COMMAND make -j install
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME make-install-${TARGET_TRIPLET}-debug
    )

    set(VERSION ${LIBSPATIALITE_VERSION_STR})
    configure_file(${SOURCE_PATH_DEBUG}/spatialite.pc.in
                   ${OUT_PATH_DEBUG}/lib/pkgconfig/spatialite.pc @ONLY)
    file(COPY ${OUT_PATH_DEBUG}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
    message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")
  endif()
else() # Other build system
  message(FATAL_ERROR "Unsupport build system.")
endif()