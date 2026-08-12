message(
    "${PORT} requires Microsoft Visual Studio with the C++ workload and the Windows Driver Kit (WDK)."
)

vcpkg_check_linkage(
    ONLY_STATIC_LIBRARY
    ONLY_STATIC_CRT
)

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_MINGW)
    message(FATAL_ERROR "crtsys supports Windows desktop MSVC/WDK triplets only.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ntoskrnl7/crtsys
    REF "v${VERSION}"
    SHA512 37acb5f8d0a047476bd96f9319db2f00d769dc9def4bfc9e2dbbee2ada33f5a4c1ecbbb8aff34a1094ffa9385b898f07ee3201b07b79a5caf62cf8344e6bd4f9
    HEAD_REF main
    PATCHES
        fix-offline-source-build.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH LDK_SOURCE_PATH
    REPO ntoskrnl7/Ldk
    REF v0.7.25
    SHA512 196680723a2a175f2eb084476f52823717e7525dea10a95da62ee28a46f4400db9c65320176e5ce8b646b12f50c4a3281a5dcad6a5726c64a5cded763b020f0f
)

vcpkg_from_github(
    OUT_SOURCE_PATH RAW_PDB_SOURCE_PATH
    REPO MolecularMatters/raw_pdb
    REF 43cc59b7037238ad84e1d5abe10711a06d998fa0
    SHA512 04c7bd7d82598692069b7e371f90deb316dea450c1bafc1b1f6be06a392b3227c7fd547d24b22e77bc70ebdd13193c01a2f72ba26b6d0acfb14ac1398e1cac40
)

vcpkg_from_github(
    OUT_SOURCE_PATH UCXXRT_SOURCE_PATH
    REPO ntoskrnl7/ucxxrt
    REF cfb00b2ad3595fa1f89a3b3a665fa742cf5aa1aa
    SHA512 eaa472ca43457a356cbbb0a802e8119694c12dbacb173bd86b88c0286411b93cd67c07c389cc09ad52221804a2685e80100d61f6b70344c846cc0a04e871cf17
)

vcpkg_download_distfile(CPM_CMAKE
    URLS "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.32.0/CPM.cmake"
    FILENAME "CPM_0.32.0.cmake"
    SHA512 7f18248e5fd3992a0752ce10009bc3862b34d29391db586f98979d5547bd910d9b4e558acaa7eb4965f0221782aac233731e54b0f1f45e18d9365564d4110eb1
)
set(CPM_SOURCE_CACHE "${CURRENT_BUILDTREES_DIR}/cpm-source-cache")
file(MAKE_DIRECTORY "${CPM_SOURCE_CACHE}/cpm")
file(COPY_FILE
    "${CPM_CMAKE}"
    "${CPM_SOURCE_CACHE}/cpm/CPM_0.32.0.cmake"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(CRTSYS_TARGET_ARCHITECTURE ARM)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(CRTSYS_TARGET_ARCHITECTURE ARM64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR
       VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CRTSYS_TARGET_ARCHITECTURE "${VCPKG_TARGET_ARCHITECTURE}")
else()
    message(FATAL_ERROR "crtsys does not support ${VCPKG_TARGET_ARCHITECTURE}.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DCRTSYS_LDK_SOURCE_DIR=${LDK_SOURCE_PATH}"
        "-DCRTSYS_RAW_PDB_SOURCE_DIR=${RAW_PDB_SOURCE_PATH}"
        "-DCRTSYS_UCXXRT_SOURCE_DIR=${UCXXRT_SOURCE_PATH}"
        "-DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE}"
        "-DCRTSYS_TARGET_ARCHITECTURE=${CRTSYS_TARGET_ARCHITECTURE}"
        -DCRTSYS_ENABLE_INSTALL=ON
        -DCRTSYS_BUILD_NTL_KERNEL_CONTENT_CODECS=OFF
        -DCRTSYS_INSTALL_CMAKEDIR=share/crtsys
    OPTIONS_RELEASE
        -DCRTSYS_INSTALL_RELEASE_LIBDIR=lib/manual-link
    OPTIONS_DEBUG
        -DCRTSYS_INSTALL_DEBUG_LIBDIR=lib/manual-link
)
vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Preserve the upstream Visual Studio property pages while the bridge selects
# the standard vcpkg manual-link directories for the chosen triplet.
file(INSTALL
    "${SOURCE_PATH}/nuget/build/native/crtsys.props"
    "${SOURCE_PATH}/nuget/build/native/crtsys.targets"
    "${SOURCE_PATH}/nuget/build/native/crtsys.xml"
    "${SOURCE_PATH}/nuget/build/native/crtsys-kmdf.xml"
    DESTINATION "${CURRENT_PACKAGES_DIR}/build/native"
)
file(INSTALL "${CURRENT_PORT_DIR}/crtsys-vcpkg.targets"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/crtsys/msbuild"
)
file(INSTALL
    "${CURRENT_PORT_DIR}/tools/crtsys-vs-init.ps1"
    "${CURRENT_PORT_DIR}/tools/crtsys-vs-init.cmd"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
)

if("msquic-headers" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH MSQUIC_SOURCE_PATH
        REPO microsoft/msquic
        REF b3945bb0c9e44463c93dac13e40975a7c3a526ca
        SHA512 3f3eb2d4d76a6246915df4abdc0588b27a2567409cc2e6fb250a9224563d65fe2c586e01ddea62d227e74f1cae9d47eb67df878a501cfe21c27a87a6988b662a
    )
    file(INSTALL
        "${MSQUIC_SOURCE_PATH}/src/inc/msquic.h"
        "${MSQUIC_SOURCE_PATH}/src/inc/msquic_winuser.h"
        "${MSQUIC_SOURCE_PATH}/src/inc/msquic_winkernel.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/crtsys/msquic/include"
    )
endif()

file(INSTALL "${CURRENT_PORT_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
file(INSTALL "${SOURCE_PATH}/README.md"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME "readme.md"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/docs/third-party-notices.md"
    "${SOURCE_PATH}/include/ntl/deps/zpp/LICENSE"
    "${SOURCE_PATH}/cmake/vendor/findwdk/LICENSE"
    "${LDK_SOURCE_PATH}/LICENSE"
    "${RAW_PDB_SOURCE_PATH}/LICENSE"
    "${UCXXRT_SOURCE_PATH}/LICENSE"
)
