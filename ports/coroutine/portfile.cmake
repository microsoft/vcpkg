include(vcpkg_common_functions)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(FATAL_ERROR "This library doesn't support x86 arch. Please use x64 instead. If it is critical, create an issue at the repo: github.com/luncliff/coroutine")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF fcd970807e9a47c250c1a4e06c7dc6d93079b684
    SHA512 517f1c1726e4adc36cd34379c545324c99861d7cb5ebd3cebe0b7132fe5b61969a00e405bc106bb8f089f37d3a7ca9b1bcdc665a5cd6dfcaaf6856be37bec5b0
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
