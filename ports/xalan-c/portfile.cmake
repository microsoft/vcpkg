include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("xalan-c currenly only supports dynamic library linkage")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "Xalan-c's buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

set(XALANC_VERSION 1.11)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xalan-c
    REF Xalan-C_1_11_0
    SHA512 c0af80cf6527237092360110963e953fce15f0140866b291d87c2d0fd91d9e8fb3b6da60a02e27f78ca7623898b5c062b0b6de5ef9f5c08ba13f6202120666ca
    HEAD_REF truck
    PATCHES
        0001-ALLOW_RTCc_IN_STL.patch
        0002-no-mfc.patch
        0003-char16_t.patch
        0004-macosx-dyld-fallback.patch
        0005-fix-ftbfs-ld-as-needed.patch
        0006-fix-testxslt-segfault.patch
        0007-fix-readme-typos.patch
        0008-remove-unary-binary-function.patch
        0009-remove-select-workaround.patch
        0010-Add-CMake-build-system.patch
)


if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(ENV{CL} "$ENV{CL} \"/I${CURRENT_INSTALLED_DIR}/include\"")
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/XalanC TARGET_PATH share/XalanC)

file(COPY ${SOURCE_PATH}/c/src/xalanc DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.hpp)

# LocalMsgIndex.hpp and LocalMsgData.hpp are here
file(GLOB NLS_INCLUDES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/xalanc/NLS/gen/*.hpp")
if(NOT NLS_INCLUDES)
    message(FATAL_ERROR "Could not locate LocalMsgIndex.hpp")
endif()
file(COPY ${NLS_INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/xalanc/PlatformSupport)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/NLS)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/util/MsgLoaders/ICU/resources)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/TestXSLT)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XalanExe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/xalanc/XPathCAPI)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xalan-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xalan-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xalan-c/copyright)