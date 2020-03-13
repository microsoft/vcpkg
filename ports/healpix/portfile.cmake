#vcpkg_fail_port_install(ON_TARGET "Windows" "OSX")

set(HEALPIX_VER 3.50)
set(HEALPIX_PACK_NAME  ${HEALPIX_VER}_2018Dec10)

vcpkg_download_distfile(ARCHIVE
    URLS "https://phoenixnap.dl.sourceforge.net/project/healpix/Healpix_${HEALPIX_VER}/Healpix_${HEALPIX_PACK_NAME}.tar.gz"
    FILENAME "Healpix_${HEALPIX_PACK_NAME}.tar.gz"
    SHA512 29fe680d757bd94651bf029654257cb67286643aad510df4c2f0b06245174411376ec1beca64feebfac14a6fc0194525170635842916d79dcaddeddd9ac6f6c7
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)
#set(ENV{CFITSIO_EXT_INC} ${CURRENT_INSTALLED_DIR}/include/cfitsio)
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH src/cxx
    COPY_SOURCE
    OPTIONS
        --with-libcfitsio-include=${CURRENT_INSTALLED_DIR}/include/cfitsio
        --with-libcfitsio-lib=${CURRENT_INSTALLED_DIR}/lib
)

vcpkg_build_make(BUILD_TARGET compile_all)
#vcpkg_fixup_pkgconfig()

# Install manually because healpix has no install target
set(OBJ_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/auto")
file(GLOB_RECURSE HEALPIX_LIBS ${OBJ_DIR}/lib/*)
file(INSTALL ${HEALPIX_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(GLOB_RECURSE HEALPIX_INCLUDES ${OBJ_DIR}/include/*)
file(INSTALL ${HEALPIX_INCLUDES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(GLOB_RECURSE HEALPIX_TOOLS ${OBJ_DIR}/bin/*)
file(INSTALL ${HEALPIX_TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/")
    set(OBJ_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/auto")
    file(GLOB_RECURSE HEALPIX_LIBS ${OBJ_DIR}/lib/*)
    file(INSTALL ${HEALPIX_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
