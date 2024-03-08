# Check library linkage:
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

# Get source code:
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO faburaya/3fd
    REF 3a0fe606268721d1560b88dcca8647c67c0b275c # v2.6.3 (Stable)
    SHA512 70630291b4055de2044ad76ef21e99d6ab6fd3468debb2a864a461cf8513642fe87f116e9dfff96ecff96f4577108493dc25aa40eeefcd93ee75990b13bb7b20
    HEAD_REF master
    PATCHES
        RapidXML.patch
)

# Build:
if (VCPKG_TARGET_IS_UWP) # UWP:
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "3FD/3FD.WinRT.UWP.vcxproj"
    )
elseif (VCPKG_TARGET_IS_WINDOWS) # Win32:
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "3FD/3FD.vcxproj"
        TARGET Build
    )
else()
    message(FATAL_ERROR "Unsupported system: 3FD is not currently ported to VCPKG in ${VCPKG_CMAKE_SYSTEM_NAME}!")
endif()

# Install:
file(GLOB HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/3FD/*.h")
file(INSTALL
    ${HEADER_FILES}
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/3FD"
    PATTERN "*_impl*.h" EXCLUDE
    PATTERN "*example*.h" EXCLUDE
    PATTERN "stdafx.h" EXCLUDE
    PATTERN "targetver.h" EXCLUDE
)

file(INSTALL "${SOURCE_PATH}/btree"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/3FD")
file(INSTALL "${SOURCE_PATH}/OpenCL/CL" DESTINATION "${CURRENT_PACKAGES_DIR}/include/3FD")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/3FD")
file(INSTALL
    "${SOURCE_PATH}/3FD/3fd-config-template.xml"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/3FD"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${SOURCE_PATH}/Acknowledgements.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/3fd")

vcpkg_copy_pdbs()
