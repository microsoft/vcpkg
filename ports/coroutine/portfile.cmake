include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF             1.4
    SHA512          981c9c728c7888995880a97e8533fa31f41085ef57e1c61e53e555f329d20d4a882d9de724d9e93e3d009dc3fe0669fe4d1af403654a9373e4aab44c933628a3
    HEAD_REF        master
)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(FATAL_ERROR "This library doesn't support x86 arch. Please use x64 instead or contact maintainer")
endif()

# package: 'ms-gsl'
message(STATUS "Using Guideline Support Library at ${CURRENT_INSTALLED_DIR}/include")

set(DLL_LINKAGE false)
if(${VCPKG_LIBRARY_LINKAGE} MATCHES dynamic)
    message(STATUS "Using DLL linkage")
    set(DLL_LINKAGE true)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        # package: 'ms-gsl'
        -DGSL_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DTEST_DISABLED=True
        -DBUILD_SHARED_LIBS=${DLL_LINKAGE}
)

vcpkg_install_cmake()

file(
    INSTALL     ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/coroutine
    RENAME      copyright
)

if(WIN32 AND DLL_LINKAGE)
    file(INSTALL        ${CURRENT_PACKAGES_DIR}/debug/lib/coroutine.dll
         DESTINATION    ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/coroutine.dll)

    file(INSTALL        ${CURRENT_PACKAGES_DIR}/lib/coroutine.dll
         DESTINATION    ${CURRENT_PACKAGES_DIR}/bin
    )
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/coroutine.dll)
endif()
# removed duplicates in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# unset used variables
unset(DLL_LINKAGE)
