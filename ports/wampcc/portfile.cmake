if (VCPKG_TARGET_IS_WINDOWS)
    message("Shared build is broken under Windows. See https://github.com/darrenjs/wampcc/issues/57")
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

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
    REF 43d10a7ccf37ec1b895742712dd4a05577b73ff1
    SHA512 e830d26de00e8f5f378145f06691cb16121c40d3bd2cd663fad9a97db37251a11b56053178b619e3a2627f0cd518b6290a8381b26e517a9f16f0246d2f91958e
    HEAD_REF master
)

# Utils build is broken under Windows
if ("utils" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "'utils' build is broken under Windows")
    endif()

    set(ENABLE_UTILS ON)
else()
    set(ENABLE_UTILS OFF)
endif()

if ("examples" IN_LIST FEATURES)
    set(ENABLE_EXAMPLES ON)
else()
    set(ENABLE_EXAMPLES OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_UTILS:BOOL=${ENABLE_UTILS}
        -DBUILD_EXAMPLES:BOOL=${ENABLE_EXAMPLES}
        -DBUILD_TESTS:BOOL=OFF # Tests build is broken
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wampcc RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
