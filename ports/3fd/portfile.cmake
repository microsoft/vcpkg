# Check library linkage:
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

# Get source code:
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO faburaya/3fd
    REF cde5d33a2e22dc6a02423334b0a8b766348cb296 # v2.8
    SHA512 7ca4a9dd72ab32c162fa4add6c9b2638094bc870bb4147dedbe6325621b91f947b9ec45f677032f98b8b32c9999a20cfa640de3e9a00f506779dca10c2a88659
    HEAD_REF master
    PATCHES
        fix_cmake.patch
        #RapidXML.patch
)

# Build:
if(0)
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") # UWP:
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "3fd/core/3fd-core-winrt.vcxproj"
        USE_VCPKG_INTEGRATION
        ALLOW_ROOT_INCLUDES
    )
elseif (NOT VCPKG_CMAKE_SYSTEM_NAME) # Win32:
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "3fd/core/3fd-core.vcxproj"
        TARGET Build
        USE_VCPKG_INTEGRATION
        ALLOW_ROOT_INCLUDES
    )
else()
    message(FATAL_ERROR "Unsupported system: 3FD is not currently ported to VCPKG in ${VCPKG_CMAKE_SYSTEM_NAME}!")
endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    )
vcpkg_cmake_install()


# Install:
file(GLOB HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/3fd/*/*.h") # TODO fix include structure
file(INSTALL
    ${HEADER_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/3FD
    PATTERN "*_impl*.h" EXCLUDE
    PATTERN "*example*.h" EXCLUDE
    PATTERN "stdafx.h" EXCLUDE
    PATTERN "targetver.h" EXCLUDE
)

file(INSTALL "${SOURCE_PATH}/btree"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/3FD")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/3FD")
file(INSTALL
    "${SOURCE_PATH}/3fd/core/3fd-config-template.xml"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/3FD"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/3fd" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/Acknowledgements.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/3fd")

vcpkg_copy_pdbs()
