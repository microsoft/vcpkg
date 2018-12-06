include(vcpkg_common_functions)

set(BOTAN_VERSION 2.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randombit/botan
    REF cb14e9ce95bcaae2ada7ffe96ef0cce6a2b38593
    SHA512 3d8fbf1c65e2b0259f225db46ffa4a7eb989a518b230574e94f82dc13afd7dc32cfe6a8a0127e7dd0dea30e06f3946db78db50e107937382eff8ed823e996dc3
    HEAD_REF master
)

vcpkg_find_acquire_program(JOM)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BOTAN_FLAG_SHARED --enable-shared-library)
    set(BOTAN_FLAG_STATIC --disable-static-library)
else()
    set(BOTAN_FLAG_SHARED --disable-shared-library)
    set(BOTAN_FLAG_STATIC --enable-static-library)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(BOTAN_MSVC_RUNTIME "--msvc-runtime=MD")
else()
    set(BOTAN_MSVC_RUNTIME "--msvc-runtime=MT")
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
        set(BOTAN_DEBUG_SUFFIX "")
        set(BOTAN_MSVC_RUNTIME_SUFFIX "d")
    else()
        set(BOTAN_FLAG_DEBUGMODE)
        set(BOTAN_FLAG_PREFIX ${CURRENT_PACKAGES_DIR})
        set(BOTAN_MSVC_RUNTIME_SUFFIX "")
    endif()

    message(STATUS "Configure ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")

    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
    endif()
    make_directory(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})

    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "${SOURCE_PATH}/configure.py"
            --cc=msvc
            --cpu=${BOTAN_FLAG_CPU}
            ${BOTAN_FLAG_SHARED}
            ${BOTAN_FLAG_STATIC}
            ${BOTAN_MSVC_RUNTIME}${BOTAN_MSVC_RUNTIME_SUFFIX}
            ${BOTAN_FLAG_DEBUGMODE}
            "--distribution-info=vcpkg ${TARGET_TRIPLET}"
            --prefix=${BOTAN_FLAG_PREFIX}
            --link-method=copy
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}"
        LOGNAME configure-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
    message(STATUS "Configure ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")

    message(STATUS "Build ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")
    vcpkg_execute_required_process(
        COMMAND ${JOM}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}"
        LOGNAME jom-build-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
    message(STATUS "Build ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")

    message(STATUS "Package ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")
    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "${SOURCE_PATH}/src/scripts/install.py"
            --prefix=${BOTAN_FLAG_PREFIX}
            --docdir=share
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}"
        LOGNAME install-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(RENAME ${BOTAN_FLAG_PREFIX}/lib/botan${BOTAN_DEBUG_SUFFIX}.dll ${BOTAN_FLAG_PREFIX}/bin/botan${BOTAN_DEBUG_SUFFIX}.dll)
    endif()

    message(STATUS "Package ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")
endfunction()

BOTAN_BUILD(rel)
BOTAN_BUILD(dbg)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/botan)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/botan-cli.exe ${CURRENT_PACKAGES_DIR}/tools/botan/botan-cli.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/botan-cli.exe)

file(RENAME ${CURRENT_PACKAGES_DIR}/include/botan-2/botan ${CURRENT_PACKAGES_DIR}/include/botan)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/include/botan-2
    ${CURRENT_PACKAGES_DIR}/share/botan-${BOTAN_VERSION}/manual)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/botan)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/botan-${BOTAN_VERSION}/ ${CURRENT_PACKAGES_DIR}/share/botan/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/botan/license.txt ${CURRENT_PACKAGES_DIR}/share/botan/copyright)
