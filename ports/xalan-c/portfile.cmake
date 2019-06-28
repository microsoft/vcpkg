include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(XALANC_VERSION 1.11)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www-us.apache.org/dist/xalan/xalan-c/sources/xalan_c-${XALANC_VERSION}-src.zip"
    FILENAME "xalan_c-${XALANC_VERSION}-src.zip"
    SHA512 2e79a2c8f755c9660ffc94b26b6bd4b140685e05a88d8e5abb19a2f271383a3f2f398b173ef403f65dc33af75206214bd21ac012c39b4c0051b3a9f61f642fe6
)

vcpkg_download_distfile(XALAN_PATCH8
    URLS "https://github.com/rleigh-codelibre/vcpkg-patches/raw/ca09d69280469ce8f787c67b48f86e46a463ef5d/xalan-c/0008-remove-unary-binary-function.patch"
    FILENAME "0008-remove-unary-binary-function.patch"
    SHA512 059d9a39b29125ae770369e4c44ab7804ae16d4ff5c90e35f25b7990dc987161bf1187ceb2dcbab181ffb72490a9d9f45e30ab5928644734e7627cb74b03e201
)

vcpkg_download_distfile(XALAN_PATCH9
    URLS "https://raw.githubusercontent.com/rleigh-codelibre/vcpkg-patches/ca09d69280469ce8f787c67b48f86e46a463ef5d/xalan-c/0009-remove-select-workaround.patch"
    FILENAME "0009-remove-select-workaround.patch"
    SHA512 73730736cd1f1809ebcc35562017402d606cbfd5a64665d104a21d89d679ab3274f6f5685ab63305c57fffab74e62084c0e18c76d19eb5f9c2e36be6679fd4d3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${XALANC_VERSION}
    PATCHES
        0001-ALLOW_RTCc_IN_STL.patch
        0002-no-mfc.patch
        0003-char16_t.patch
        0004-macosx-dyld-fallback.patch
        0005-fix-ftbfs-ld-as-needed.patch
        0006-fix-testxslt-segfault.patch
        0007-fix-readme-typos.patch
        ${XALAN_PATCH8}
        ${XALAN_PATCH9}
)

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(ENV{CL} "$ENV{CL} \"/I${CURRENT_INSTALLED_DIR}/include\"")
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH c/projects/Win32/VC10/AllInOne/AllInOne.vcxproj
    OPTIONS_RELEASE /p:XERCESCROOT=${CURRENT_INSTALLED_DIR}
    OPTIONS_DEBUG /p:XERCESCROOT=${CURRENT_INSTALLED_DIR}/debug
    LICENSE_SUBPATH c/LICENSE
    SKIP_CLEAN
)

file(COPY ${SOURCE_PATH}/c/src/xalanc DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.hpp)

# LocalMsgIndex.hpp and LocalMsgData.hpp are here
file(GLOB NLS_INCLUDES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/c/Build/*/VC10/Release/Nls/Include/*.hpp")
if(NOT NLS_INCLUDES)
    message(FATAL_ERROR "Could not locate LocalMsgIndex.hpp")
endif()
file(COPY ${NLS_INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/xalanc/PlatformSupport)

vcpkg_clean_msbuild()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/NLS)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/util/MsgLoaders/ICU/resources)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/TestXSLT)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XalanExe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XPathCAPI)
