include(vcpkg_common_functions)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(WARNING "This library may not work correctly in x86 arch. Please consider using x64 instead")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF             1.5.0
    SHA512          b07eb50a4af2db322d0fc2ade715b2e758afe70f2de62576161e0c570027d58b0ccdad6cce4c6e7f1d5488c1f23a50a4e9ff4ac1c0cc04f0e419c5f7285e67b4
    HEAD_REF        master
)

# package: 'ms-gsl'
set(GSL_INCLUDE_DIR ${CURRENT_INSTALLED_DIR}/include
    CACHE PATH "path to include C++ CoreGuidelines Support Library" FORCE)
message(STATUS "using ms-gsl(vcpkg): ${GSL_INCLUDE_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_INCLUDE_DIR=${GSL_INCLUDE_DIR}
        -DBUILD_TESTING=False
)
vcpkg_install_cmake()
if(WIN32)
    vcpkg_copy_pdbs()
endif()

file(INSTALL     ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/coroutine
     RENAME      copyright
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
