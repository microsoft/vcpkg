include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(XALAN_C_VERSION 1.11)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www-us.apache.org/dist/xalan/xalan-c/sources/xalan_c-${XALAN_C_VERSION}-src.zip"
    FILENAME "xalan_c-${XALAN_C_VERSION}-src.zip"
    SHA512 2e79a2c8f755c9660ffc94b26b6bd4b140685e05a88d8e5abb19a2f271383a3f2f398b173ef403f65dc33af75206214bd21ac012c39b4c0051b3a9f61f642fe6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${XALAN_C_VERSION}
    PATCHES
        0001-ALLOW_RTCc_IN_STL.patch
        0002-no-mfc.patch
        0003-char16_t.patch
        0004-macosx-dyld-fallback.patch
        0005-fix-ftbfs-ld-as-needed.patch
        0006-fix-testxslt-segfault.patch
        0007-fix-readme-typos.patch
)

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(BUILD_ARCH "Win32")
    set(OUTPUT_DIR "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(BUILD_ARCH "x64")
    set(OUTPUT_DIR "Win64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/c/projects/Win32/VC10/AllInOne/AllInOne.vcxproj
    PLATFORM ${BUILD_ARCH}
    USE_VCPKG_INTEGRATION
)

# This is needed to generate the required LocalMsgIndex.hpp header
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/c/projects/Win32/VC10/Utils/XalanMsgLib/XalanMsgLib.vcxproj
    PLATFORM ${BUILD_ARCH}
    USE_VCPKG_INTEGRATION
)

file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Debug/XalanMessages_1_11D.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Debug/Xalan-C_1_11D.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Debug/Xalan-C_1D.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/XalanMessages_1_11.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/Xalan-C_1_11.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/Xalan-C_1.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(COPY ${SOURCE_PATH}/c/src/xalanc DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.hpp)

# LocalMsgIndex.hpp is here
file(COPY ${SOURCE_PATH}/c/Build/${OUTPUT_DIR}/VC10/Release/Nls/Include/LocalMsgIndex.hpp 
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/xalanc/PlatformSupport)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/NLS)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/util/MsgLoaders/ICU/resources)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/TestXSLT)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XalanExe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XPathCAPI)

# Handle copyright
file(COPY ${SOURCE_PATH}/c/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xalan-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xalan-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xalan-c/copyright)

vcpkg_copy_pdbs()
