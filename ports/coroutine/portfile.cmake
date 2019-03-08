include(vcpkg_common_functions)

# The tagged commit for release 1.4 was changed by the library's author.
# The current commit for release 1.4 is 3f804ca0f9ec94e3c85e3c5cc00aecc577fb8aad
# We use the commit's hash to avoid the tag changing again it in the future.
set(VERSION_1_4_COMMIT 3f804ca0f9ec94e3c85e3c5cc00aecc577fb8aad)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF             ${VERSION_1_4_COMMIT}
    SHA512          a77d66a8d485a99278f15652d26f255653824c47bd3653233e89ddb6368bc3b45ab0a8049e504c5acc8cf051da582bf6b4d8461c8f7f57bf5a0b7dcaddc0afbb
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
