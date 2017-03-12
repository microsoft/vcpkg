include(vcpkg_common_functions)

set(BOTAN_VERSION 2.0.1)
set(BOTAN_HASH  c5062ce92a6e6e333b4e6af095ed54d0c4ffacefc6ac87ec651dd1e0937793c9956b7c9c0d3acf49f059505526584168364e01c55ab72c953ad255e8396aed35)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/Botan-${BOTAN_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://botan.randombit.net/releases/Botan-${BOTAN_VERSION}.tgz"
    FILENAME "Botan-${BOTAN_VERSION}.tgz"
    SHA512 ${BOTAN_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH} 
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-crt-linking.patch")

vcpkg_find_acquire_program(JOM)
vcpkg_find_acquire_program(PYTHON3)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BOTAN_FLAG_SHARED --disable-shared)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BOTAN_FLAG_CPU x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(BOTAN_FLAG_CPU x86_64)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

function(BOTAN_BUILD BOTAN_BUILD_TYPE)

    if(BOTAN_BUILD_TYPE STREQUAL "dbg")
        set(BOTAN_FLAG_PREFIX ${CURRENT_PACKAGES_DIR}/debug)
        set(BOTAN_FLAG_DEBUGMODE --debug-mode)
        set(BOTAN_DEBUG_PREFIX d)
    else()
        set(BOTAN_FLAG_PREFIX ${CURRENT_PACKAGES_DIR})
    endif()
   
    message(STATUS "Configure ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")

    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "configure.py" 
            --cc=msvc
            --cpu=${BOTAN_FLAG_CPU}
            ${BOTAN_FLAG_SHARED} 
            ${BOTAN_FLAG_DEBUGMODE}
            --makefile-style=nmake
            --with-pkcs11
            --prefix=${BOTAN_FLAG_PREFIX}
            --link-method=copy          
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME configure-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
    message(STATUS "Configure ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")

    message(STATUS "Build ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")
    vcpkg_execute_required_process(
        COMMAND ${JOM}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME jom-build-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
    message(STATUS "Build ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")

    message(STATUS "Package ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")
    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "src/scripts/install.py" 
            --destdir=${BOTAN_FLAG_PREFIX}
            --build-dir=build
            --docdir=share 
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME install-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})

    file(MAKE_DIRECTORY ${BOTAN_FLAG_PREFIX}/tools/)
    file(RENAME ${BOTAN_FLAG_PREFIX}/bin/botan-cli.exe ${BOTAN_FLAG_PREFIX}/tools/botan-cli.exe)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(RENAME ${BOTAN_FLAG_PREFIX}/lib/botan${BOTAN_DEBUG_PREFIX}.dll ${BOTAN_FLAG_PREFIX}/bin/botan${BOTAN_DEBUG_PREFIX}.dll)
        if(BOTAN_BUILD_TYPE STREQUAL dbg)
            file(COPY ${SOURCE_PATH}/botan${BOTAN_DEBUG_PREFIX}.pdb DESTINATION ${BOTAN_FLAG_PREFIX}/bin/)
        endif()
    endif()
    
    message(STATUS "Package ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")
endfunction()   

BOTAN_BUILD(rel)
BOTAN_BUILD(dbg)

file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/botan-${BOTAN_VERSION}/manual)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE 
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/botan-${BOTAN_VERSION}/ ${CURRENT_PACKAGES_DIR}/share/botan/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/botan/license.txt ${CURRENT_PACKAGES_DIR}/share/botan/copyright)
