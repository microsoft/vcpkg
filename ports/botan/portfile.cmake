vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randombit/botan
    REF d4bd416702a65eddcc14ee06b9c1b674631e6ae3 # 2.18.1
    SHA512 6c8a8a772ff926402aa77ea1156e8a6b8fcaa18514107c94e9d2c7c76daaf9a02ef8c5c249d1ddf56655bab0ecd0d91490d907fc2239259689662533089b09ad
    HEAD_REF master
    PATCHES
        fix-generate-build-path.patch
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
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(BOTAN_FLAG_CPU arm32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(BOTAN_FLAG_CPU arm64)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        amalgamation BOTAN_AMALGAMATION
)

function(BOTAN_BUILD BOTAN_BUILD_TYPE)

    if(BOTAN_BUILD_TYPE STREQUAL "dbg")
        set(BOTAN_FLAG_PREFIX "${CURRENT_PACKAGES_DIR}/debug")
        set(BOTAN_FLAG_DEBUGMODE --debug-mode)
        set(BOTAN_DEBUG_SUFFIX "")
        set(BOTAN_MSVC_RUNTIME_SUFFIX "d")
    else()
        set(BOTAN_FLAG_DEBUGMODE)
        set(BOTAN_FLAG_PREFIX "${CURRENT_PACKAGES_DIR}")
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
                            --with-pkg-config
                            --link-method=copy)
    if(CMAKE_HOST_WIN32)
        list(APPEND configure_arguments ${BOTAN_MSVC_RUNTIME}${BOTAN_MSVC_RUNTIME_SUFFIX})
    endif()

    if("-DBOTAN_AMALGAMATION=ON" IN_LIST FEATURE_OPTIONS)
        list(APPEND configure_arguments --amalgamation)
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
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}"
        LOGNAME install-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE})

    message(STATUS "Package ${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE} done")
endfunction()

BOTAN_BUILD(rel)
BOTAN_BUILD(dbg)

file(RENAME "${CURRENT_PACKAGES_DIR}/include/botan-2/botan" "${CURRENT_PACKAGES_DIR}/include/botan")

vcpkg_copy_pdbs()

if(CMAKE_HOST_WIN32)
    vcpkg_copy_tools(TOOL_NAMES botan-cli AUTO_CLEAN)
else()
    vcpkg_copy_tools(TOOL_NAMES botan AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/botan-2"
    "${CURRENT_PACKAGES_DIR}/share/doc")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
