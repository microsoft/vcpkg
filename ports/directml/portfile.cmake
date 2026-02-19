vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

# DirectML provides DirectML.Debug.dll. They will be installed with release DLLs
set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

# see https://www.nuget.org/packages/Microsoft.AI.DirectML/
# see https://github.com/microsoft/DirectML/blob/master/Releases.md
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.AI.DirectML/${VERSION}"
         "https://globalcdn.nuget.org/packages/microsoft.ai.directml.${VERSION}.nupkg"
    FILENAME "Microsoft.AI.DirectML-${VERSION}.zip"
    SHA512 fde767f56904abc90fd53f65d8729c918ab7f6e3c5e1ecdd479908fc02b4535cf2b0860f7ab2acb9b731d6cb809b72c3d5d4d02853fb8f5ea022a47bc44ef285
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(TRIPLE "x64-win")
        # check community triplets...
        if(DEFINED VCPKG_XBOX_CONSOLE_TARGET AND (VCPKG_XBOX_CONSOLE_TARGET MATCHES "scarlett"))
            set(TRIPLE "x64-xbox-scarlett-231000")
        endif()
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(TRIPLE "x86-win")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64ec")
        set(TRIPLE "arm64ec-win")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(TRIPLE "arm64-win")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(TRIPLE "arm-win")
    else()
        message(FATAL_ERROR "The architecture '${VCPKG_TARGET_ARCHITECTURE}' is not supported")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(TRIPLE "x64-linux")
    else()
        message(FATAL_ERROR "The architecture '${VCPKG_TARGET_ARCHITECTURE}' is not supported")
    endif()
else()
    message(FATAL_ERROR "The triplet '${TARGET_TRIPLET}' is not supported")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${SOURCE_PATH}/bin/${TRIPLE}/DirectML.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    )
    file(INSTALL "${SOURCE_PATH}/bin/${TRIPLE}/DirectML.dll"
                 "${SOURCE_PATH}/bin/${TRIPLE}/DirectML.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
    )
    # Install debug artifacts only if they exist upstream to avoid mismatched debug/release
    if(EXISTS "${SOURCE_PATH}/bin/${TRIPLE}/DirectML.Debug.dll")
        file(INSTALL "${SOURCE_PATH}/bin/${TRIPLE}/DirectML.Debug.dll"  DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    endif()
    if(EXISTS "${SOURCE_PATH}/bin/${TRIPLE}/DirectML.Debug.pdb")
        file(INSTALL "${SOURCE_PATH}/bin/${TRIPLE}/DirectML.Debug.pdb"  DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    file(INSTALL "${SOURCE_PATH}/bin/${TRIPLE}/libdirectml.so"  DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
    message(FATAL_ERROR "The target platform is not supported")
endif()

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE-CODE.txt"
             "${SOURCE_PATH}/README.md"
             "${SOURCE_PATH}/ThirdPartyNotices.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
