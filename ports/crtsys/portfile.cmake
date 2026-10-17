message(
    "${PORT} requires Microsoft Visual Studio with the C++ workload and a "
    "system-installed Windows Driver Kit (WDK)."
)

vcpkg_check_linkage(
    ONLY_STATIC_LIBRARY
    ONLY_STATIC_CRT
)

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_MINGW)
    message(FATAL_ERROR "crtsys supports Windows desktop MSVC/WDK triplets only.")
endif()

# Start the curated port with the configuration exercised by its test port.
# Other upstream architectures can be added after they have equivalent
# installed-package driver-link tests in scripts/test_ports.
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR
        "The curated crtsys port currently supports x64 only."
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ntoskrnl7/crtsys
    REF "v${VERSION}"
    SHA512 704c877ff4422972bd31c47249548cb67319ea974c24a0e8cbb50b4ca39c69286920230325fd504a46a6b6f1a9d302d72407f9cee70e4f0223a480aa8bdf7c07
    HEAD_REF main
    PATCHES
        # v0.1.42 still enables the legacy ucxxrt path for pre-v142 toolsets.
        # The curated port supports v142 and newer and fails clearly otherwise.
        disable-legacy-ucxxrt.patch
        use-local-dependencies-without-cpm.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH LDK_SOURCE_PATH
    REPO ntoskrnl7/Ldk
    REF v0.7.25
    SHA512 196680723a2a175f2eb084476f52823717e7525dea10a95da62ee28a46f4400db9c65320176e5ce8b646b12f50c4a3281a5dcad6a5726c64a5cded763b020f0f
    PATCHES
        ldk-use-local-findwdk.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH RAW_PDB_SOURCE_PATH
    REPO MolecularMatters/raw_pdb
    REF 43cc59b7037238ad84e1d5abe10711a06d998fa0
    SHA512 04c7bd7d82598692069b7e371f90deb316dea450c1bafc1b1f6be06a392b3227c7fd547d24b22e77bc70ebdd13193c01a2f72ba26b6d0acfb14ac1398e1cac40
)

# crtsys uses WDK CMake functions that require a Visual Studio generator.
# Local source paths and CRTSYS_REQUIRE_LOCAL_DEPENDENCIES keep CPM and network
# dependency resolution out of the port build.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        "-DCRTSYS_LDK_SOURCE_DIR=${LDK_SOURCE_PATH}"
        "-DCRTSYS_RAW_PDB_SOURCE_DIR=${RAW_PDB_SOURCE_PATH}"
        "-DLDK_FINDWDK_SOURCE_DIR=${SOURCE_PATH}/cmake/vendor/findwdk"
        -DCRTSYS_REQUIRE_LOCAL_DEPENDENCIES=ON
        -DCRTSYS_TARGET_ARCHITECTURE=x64
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

# The curated package never enables the upstream opt-in network fallback.
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/crtsys/CPM.cmake")

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
    "${CURRENT_PORT_DIR}/microsoft-runtime-notice.txt"
)
