include(vcpkg_common_functions)

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

# Check library linkage:
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

# Get source code:
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO faburaya/3FD
    REF v2.6.2
    SHA512 a2444cc07d8741540c6071ac59bc8c63785db52e412a843aa18a5dfa0144b5001d428e44bcb520238e3d476440bc74526343f025005f05d534e732645f59cbe0
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/remove-seekpos.patch"
        "${CMAKE_CURRENT_LIST_DIR}/DataException.patch"
        "${CMAKE_CURRENT_LIST_DIR}/RapidXML.patch"
)

# Copy the sources to ensure a clean, out-of-source build
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-all)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-all)
file(COPY ${SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-all)
get_filename_component(LAST_DIR_NAME "${SOURCE_PATH}" NAME)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-all/${LAST_DIR_NAME}")

# Build:
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") # UWP:
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH ${SOURCE_PATH}/3FD/3FD.WinRT.UWP.vcxproj
        PLATFORM ${BUILD_ARCH}
    )
elseif (NOT VCPKG_CMAKE_SYSTEM_NAME) # Win32:
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH ${SOURCE_PATH}/3FD/3FD.vcxproj
        PLATFORM ${BUILD_ARCH}
        TARGET Build
    )
else()
    message(FATAL_ERROR "Unsupported system: 3FD is not currently ported to VCPKG in ${VCPKG_CMAKE_SYSTEM_NAME}!")
endif()

# Install:
file(GLOB HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/3FD/*.h")
file(INSTALL
    ${HEADER_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/3FD
    PATTERN "*_impl*.h" EXCLUDE
    PATTERN "*example*.h" EXCLUDE
    PATTERN "stdafx.h" EXCLUDE
    PATTERN "targetver.h" EXCLUDE
)

file(INSTALL ${SOURCE_PATH}/btree  DESTINATION ${CURRENT_PACKAGES_DIR}/include/3FD)
file(INSTALL ${SOURCE_PATH}/OpenCL/CL DESTINATION ${CURRENT_PACKAGES_DIR}/include/3FD)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/3FD)
file(INSTALL
    ${SOURCE_PATH}/3FD/3fd-config-template.xml
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/3FD
)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") # Visual C++, UWP app:
    file(INSTALL
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Debug/3FD.WinRT.UWP/3FD.WinRT.UWP.lib
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Debug/3FD.WinRT.UWP/_3FD_WinRT_UWP.pri
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Debug/WinRT.UWP/3FD.WinRT.UWP.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Release/3FD.WinRT.UWP/3FD.WinRT.UWP.lib
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Release/3FD.WinRT.UWP/_3FD_WinRT_UWP.pri
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Release/WinRT.UWP/3FD.WinRT.UWP.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
else() # Visual C++, Win32 app:
    file(INSTALL
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Debug/3FD.lib
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Debug/3FD.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Release/3FD.lib
        ${SOURCE_PATH}/3FD/${BUILD_ARCH}/Release/3FD.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/3fd RENAME copyright)
file(INSTALL ${SOURCE_PATH}/Acknowledgements.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/3fd)

vcpkg_copy_pdbs()
