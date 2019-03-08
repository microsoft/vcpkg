include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF             1.4
    SHA512          6154988fca025a196d68ca025ce95fd972ed8aed15475d4da9d4038a4a3f498b1e0a4f570ff250f3a45e97b79ac6a2a2fe08abe645a389d5f1a68fd89cc58021
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
