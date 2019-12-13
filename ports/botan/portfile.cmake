set(BOTAN_VERSION 2.12.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randombit/botan
    REF 1a6ad661ce64287ccbe26460ccc3aa4247d86ba8 # 2.12.1
    SHA512 7a774f325c85761e2d076847f1fc8bc67592d696c4ebde839928591f7c85352e2df6032c122bdcc603adf84d76f5a1897c7118aa3859d38f79e474f27bc3b588
    HEAD_REF master
    PATCHES fix-generate-build-path.patch
)

if(CMAKE_HOST_WIN32)
    vcpkg_find_acquire_program(JOM)
    set(build_tool "${JOM}")
    set(parallel_build "/J${VCPKG_CONCURRENCY}")
else()
    find_program(MAKE make)
    set(build_tool "${MAKE}")
    set(parallel_build "-j${VCPKG_CONCURRENCY}")
endif()

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

    set(configure_arguments --cpu=${BOTAN_FLAG_CPU}
                            ${BOTAN_FLAG_SHARED}
                            ${BOTAN_FLAG_STATIC}
                            ${BOTAN_FLAG_DEBUGMODE}
                            "--distribution-info=vcpkg ${TARGET_TRIPLET}"
                            --prefix=${BOTAN_FLAG_PREFIX}
                            --link-method=copy)
    if(CMAKE_HOST_WIN32)
        list(APPEND configure_arguments ${BOTAN_MSVC_RUNTIME}${BOTAN_MSVC_RUNTIME_SUFFIX})
    endif()

    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "${SOURCE_PATH}/configure.py" ${configure_arguments}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}"
        LOGNAME configure-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
    message(STATUS "Configure ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")

    message(STATUS "Build ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")
    vcpkg_execute_build_process(
        COMMAND "${build_tool}" ${parallel_build}
        NO_PARALLEL_COMMAND "${build_tool}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}"
        LOGNAME build-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})
    message(STATUS "Build ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")

    message(STATUS "Package ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}")
    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "${SOURCE_PATH}/src/scripts/install.py"
            --prefix=${BOTAN_FLAG_PREFIX}
            --bindir=${BOTAN_FLAG_PREFIX}/bin
            --libdir=${BOTAN_FLAG_PREFIX}/lib
            --pkgconfigdir=${BOTAN_FLAG_PREFIX}/lib
            --includedir=${BOTAN_FLAG_PREFIX}/include
            --docdir=${BOTAN_FLAG_PREFIX}/share
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}"
        LOGNAME install-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND CMAKE_HOST_WIN32)
        file(RENAME ${BOTAN_FLAG_PREFIX}/lib/botan${BOTAN_DEBUG_SUFFIX}.dll ${BOTAN_FLAG_PREFIX}/bin/botan${BOTAN_DEBUG_SUFFIX}.dll)
    endif()

    message(STATUS "Package ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")
endfunction()

BOTAN_BUILD(rel)
BOTAN_BUILD(dbg)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/botan)

set(cli_exe_name "botan")
if(CMAKE_HOST_WIN32)
    set(cli_exe_name "botan-cli.exe")
endif()
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${cli_exe_name} ${CURRENT_PACKAGES_DIR}/tools/botan/${cli_exe_name})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${cli_exe_name})

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
