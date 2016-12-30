if (VCPKG_TARGET_ARCHITECTURE STREQUAL arm OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: ARM and/or UWP builds are currently not supported.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/icu)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.icu-project.org/files/icu4c/58.2/icu4c-58_2-src.zip"
    FILENAME "icu4c-58_2-src.zip"
    SHA512 b985b553186d11d9e5157fc981af5483c435a7b4f3df9574d253d6229ecaf8af0f722488542c3f64f9726ad25e17978eae970d78300a55479df74495f6745d16)
vcpkg_extract_source_archive(${ARCHIVE})

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(BUILD_ARCH "Win32")
else()
    set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/source/allinone/allinone.sln
    PLATFORM ${BUILD_ARCH})

# force rebuild of database as it sometimies gets overriden by dummy one
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/source/data/makedata.vcxproj
    PLATFORM ${BUILD_ARCH})

set(ICU_VERSION 58)
if(TRIPLET_SYSTEM_ARCH MATCHES "x64")
    set(ICU_BIN bin64)
    set(ICU_LIB lib64)
else()
    set(ICU_BIN bin)
    set(ICU_LIB lib)
endif()

function(install_module MODULENAME)
    if(${MODULENAME} STREQUAL icudt) # Database doesn't have debug mode
        set(DEBUG_DLLNAME ${MODULENAME}${ICU_VERSION}.dll)
        set(DEBUG_LIBNAME ${MODULENAME}.lib)
    else()
        set(DEBUG_DLLNAME ${MODULENAME}${ICU_VERSION}d.dll)
        set(DEBUG_LIBNAME ${MODULENAME}d.lib)
    endif()
    set(RELEASE_DLLNAME ${MODULENAME}${ICU_VERSION}.dll)
    set(RELEASE_LIBNAME ${MODULENAME}.lib)
    file(INSTALL
        ${SOURCE_PATH}/${ICU_BIN}/${RELEASE_DLLNAME}
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL
        ${SOURCE_PATH}/${ICU_BIN}/${DEBUG_DLLNAME}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL
        ${SOURCE_PATH}/${ICU_LIB}/${RELEASE_LIBNAME}
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL
        ${SOURCE_PATH}/${ICU_LIB}/${DEBUG_LIBNAME}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endfunction()

install_module(icuuc) # Common library
install_module(icuio) # Unicode stdio
install_module(icutu) # Tool utility library
install_module(icuin) # I18n library
install_module(icudt) # Database

vcpkg_copy_pdbs()
	
file(INSTALL
    ${SOURCE_PATH}/include/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)
	
file(COPY 
    ${SOURCE_PATH}/LICENSE 
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/icu)
file(RENAME 
    ${CURRENT_PACKAGES_DIR}/share/icu/LICENSE 
    ${CURRENT_PACKAGES_DIR}/share/icu/copyright)
