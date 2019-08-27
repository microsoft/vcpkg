include(vcpkg_common_functions)

# Shared build is broken under Windows. See https://github.com/darrenjs/wampcc/issues/57
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Check architecture:
if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BUILD_ARCH "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(BUILD_ARCH "x64")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(BUILD_ARCH "ARM")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO darrenjs/wampcc
    
    # master on 27/08/2019
    REF 43d10a7ccf37ec1b895742712dd4a05577b73ff1
    
    SHA512 e830d26de00e8f5f378145f06691cb16121c40d3bd2cd663fad9a97db37251a11b56053178b619e3a2627f0cd518b6290a8381b26e517a9f16f0246d2f91958e
    HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(USE_STATIC_RUNTIME ON)
else()
    set(USE_STATIC_RUNTIME OFF)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(USE_SHARED_RUNTIME ON)
else()
    set(USE_SHARED_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_STATIC_LIBS:BOOL=${USE_STATIC_RUNTIME}
        -DBUILD_SHARED_LIBS:BOOL=${USE_SHARED_RUNTIME}
        -DBUILD_UTILS:BOOL=OFF
        -DBUILD_EXAMPLES:BOOL=OFF
        -DBUILD_TESTS:BOOL=OFF
)
vcpkg_install_cmake()


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wampcc RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

