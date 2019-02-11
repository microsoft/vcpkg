include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luncliff/coroutine
    REF be75a5dd2b2b85233b7260bc6aabeb924d8ebeb8
    SHA512 edd8f9384ba75f10038892e55f0937edfdb8987affbee04d8f5680306fc3f72c69db4f84f31142b18edb24bb057f0c984d0b90de0adb0ca0521b0fece6dae523
    HEAD_REF vcpkg
)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(FATAL_ERROR "This library doesn't support x86 arch. Please use x64 instead or contact maintainer")
endif()

# package: 'ms-gsl'
message(STATUS "Using GSL with header path: ${CURRENT_INSTALLED_DIR}/include")

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

if(WIN32) # for win32, move dll files to bin
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