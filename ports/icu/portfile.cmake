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
    URLS "http://download.icu-project.org/files/icu4c/58.1/icu4c-58_1-src.zip"
    FILENAME "icu4c-58_1-src.zip"
    SHA512 b13b1d8aa5e6a08a5cecaea85252354150064ef98ed7bb66b70d32eac5c80874c11f1fc9e3a667075b867fcc848c33ad90e6cada3a279f65b62cb9d46e25181d)
vcpkg_extract_source_archive(${ARCHIVE})

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(BUILD_ARCH "Win32")
else()
    set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/source/allinone/allinone.sln
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
