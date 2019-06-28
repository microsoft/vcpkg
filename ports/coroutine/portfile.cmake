include(vcpkg_common_functions)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(FATAL_ERROR "This library doesn't support x86 arch. Please use x64 instead. If it is critical, create an issue at the repo: github.com/luncliff/coroutine")
endif()

# changed to 1.4.2
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF             1.4.2
    SHA512          fc2544116a5bee97b8ef1501fc7f1b805248f0a0c601111f1a317e813aa1d3f9a2e08ab1b140cc36e22d9c90249301110ec5b5e55a40fb39217cf5f40998920d
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

# removed duplicates in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
