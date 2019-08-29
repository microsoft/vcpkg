include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    message(FATAL_ERROR "Unsupported system: ${VCPKG_CMAKE_SYSTEM_NAME}")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BUILD_ARCH "Win32")
    set(ARCH "32")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(BUILD_ARCH "x64")
    set(ARCH "64")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(VERSION 5.2)

vcpkg_download_distfile(ARCHIVE
    URLS "http://baical.net/files/libP7Client_v${VERSION}.zip"
    FILENAME "libP7Client_v${VERSION}.zip"
    SHA512 9744b9c3f091db90aca3485408d3e1169317152ea353ab3845cd7cfb9d61d105b55be17ad83c5970e01d7d0f37566313bc18c0f8a4c16bcd1582cd7a5ea29b87
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    NO_REMOVE_ONE_LEVEL
    REF ${VERSION}
    PATCHES
        "fix-runtime-library.patch"
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/Sources/P7ClientLib.vcxproj
        PLATFORM ${BUILD_ARCH}
        RELEASE_CONFIGURATION 
        DEBUG_CONFIGURATION 
        OPTIONS
            "/p:NoWarn=C4996" 
    )

    file(GLOB LIB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}.lib")
    file(GLOB D_LIB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}d.lib")
else()
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/Sources/P7ClientDll.vcxproj
        PLATFORM ${BUILD_ARCH}
        #RELEASE_CONFIGURATION 
        #DEBUG_CONFIGURATION 
        OPTIONS
            "/p:NoWarn=C4996"
    )

    file(GLOB DLL_LIB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}.dll.lib")
    file(GLOB D_DLL_LIB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}d.dll.lib")

    file(GLOB DLL_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}.dll")
    file(GLOB D_DLL_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}d.dll")

    file(GLOB PDB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}.pdb")
    file(GLOB D_PDB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}d.pdb")

endif()

file(GLOB HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Headers/*.h")
file(INSTALL
    ${HEADER_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/P7
)

#file(GLOB EXE_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}.exe")
#file(GLOB D_EXE_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Binaries/*${ARCH}d.exe")

file(INSTALL
    ${LIB_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${D_LIB_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${DLL_LIB_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${D_DLL_LIB_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${DLL_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${D_DLL_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${PDB_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${D_PDB_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libp7client RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()