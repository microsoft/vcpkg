include(vcpkg_common_functions)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(FATAL_ERROR "This library doesn't support x86 arch. Please use x64 instead. If it is critical, create an issue at the repo: github.com/luncliff/coroutine")
endif()

# changed to 1.4.1
set(VERSION_1_4_COMMIT 8399236a4adf1cb49ef51133fb887027e3d77141)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF             ${VERSION_1_4_COMMIT}
    SHA512          35adf0aa3a923b869e02d1e33987f6c9922f90918e84feaf5a41e46334b7555db75f55c6dd797f74112010ef5e682ee6f5fbf58be84af88a8f8f084f3d6dac05
    HEAD_REF        master
)

# package: 'ms-gsl'
set(GSL_INCLUDE_DIR ${CURRENT_INSTALLED_DIR}/include
    CACHE PATH "path to include C++ core guideline support library" FORCE)
message(STATUS "Using ms-gsl at ${GSL_INCLUDE_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_INCLUDE_DIR=${GSL_INCLUDE_DIR}
        -DTEST_DISABLED=True
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
