if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
    message(FATAL_ERROR "CHMLIB SUPPORTS STATIC LINKING ONLY.")
endif()

set(CHMLIB_VERSION chmlib-0.40)
set(CHMLIB_FILENAME ${CHMLIB_VERSION}.zip)
set(CHMLIB_URL http://www.jedrea.com/chmlib/${CHMLIB_FILENAME})
set(CHMLIB_SRC ${CURRENT_BUILDTREES_DIR}/src/${CHMLIB_VERSION}/src)
include(vcpkg_common_functions)

vcpkg_download_distfile(
    ARCHIVE
    URLS ${CHMLIB_URL}
    FILENAME ${CHMLIB_FILENAME}
    SHA512 ad3b0d49fcf99e724c0c38b9c842bae9508d0e4ad47122b0f489c113160f5344223d311abb79f25cbb0b662bb00e2925d338d60dd20a0c309bda2822cda4cd24
)   
vcpkg_extract_source_archive(${ARCHIVE})

file(GLOB VCXPROJS "${VCPKG_ROOT_DIR}/ports/${PORT}/*.vcxproj")
file(COPY ${VCXPROJS} DESTINATION ${CHMLIB_SRC})

vcpkg_build_msbuild(
    PROJECT_PATH ${CHMLIB_SRC}/chm.vcxproj
    RELEASE_CONFIGURATION Release
    DEBUG_CONFIGURATION Debug
    OPTIONS_DEBUG /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    OPTIONS_RELEASE /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS /v:diagnostic /p:SkipInvalidConfigurations=true
)

#enum_chmLib RELEASE only
vcpkg_build_msbuild(
    PROJECT_PATH ${CHMLIB_SRC}/enum_chmLib.vcxproj
    RELEASE_CONFIGURATION Release
    DEBUG_CONFIGURATION Release
    TARGET Build
    OPTIONS_DEBUG /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS_RELEASE /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS /v:diagnostic /p:SkipInvalidConfigurations=true
)

#enumdir_chmLib RELEASE only
vcpkg_build_msbuild(
    PROJECT_PATH ${CHMLIB_SRC}/enumdir_chmLib.vcxproj
    RELEASE_CONFIGURATION Release
    DEBUG_CONFIGURATION Release
    TARGET Build
    OPTIONS_DEBUG /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS_RELEASE /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS /v:diagnostic /p:SkipInvalidConfigurations=true
)

#extract_chmLib RELEASE only
vcpkg_build_msbuild(
    PROJECT_PATH ${CHMLIB_SRC}/extract_chmLib.vcxproj
    RELEASE_CONFIGURATION Release
    DEBUG_CONFIGURATION Release
    TARGET Build
    OPTIONS_DEBUG /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS_RELEASE /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS /v:diagnostic /p:SkipInvalidConfigurations=true
)

file(INSTALL ${CHMLIB_SRC}/chm_lib.h  DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/chm.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/chm.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/enum_chmLib.exe  DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/enumdir_chmLib.exe  DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/extract_chmLib.exe  DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/chmlib-0.40/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/chmlib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/chmlib/COPYING ${CURRENT_PACKAGES_DIR}/share/chmlib/copyright)