vcpkg_download_distfile(ARM64_WINDOWS_UWP_PATCH
    URLS "https://patch-diff.githubusercontent.com/raw/OpenMathLib/OpenBLAS/pull/4926.diff?full_index=1"
    FILENAME "openblas-fix-arm64-windows-uwp.patch"
    SHA512 808d375628499641f1134b4751c9861384b719dae14cf6bd4d9d4b09c9bfd9f8b13b2663e9fa9d09867b5b40817c26387ac659d2f6459d40a46455b2f540d018
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenMathLib/OpenBLAS
    REF "v${VERSION}"
    SHA512 358301c8a60bedf920c07a110c772feb639e52412bd783789741fd2fd0686aac97e6b17ebcdf01ce48a2a15841058f82df0fee551af952f6e70b58140c055133
    HEAD_REF develop
    PATCHES
        arm32-asm-function.diff
        disable-testing.diff
        getarch.diff
        system-check-msvc.diff
        win32-uwp.diff
        ${ARM64_WINDOWS_UWP_PATCH}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        threads        USE_THREAD
        simplethread   USE_SIMPLE_THREADED_LEVEL3
        dynamic-arch   DYNAMIC_ARCH
)

# If not explicitly configured for a cross build, OpenBLAS wants to run 
# getarch executables in order to optimize for the target.
# Adapting this to vcpkg triplets:
# - install-getarch.diff introduces and uses GETARCH_BINARY_DIR,
# - architecture and system name are required to match for GETARCH_BINARY_DIR, but
# - uwp (aka WindowsStore) may run windows getarch.
string(REPLACE "WindowsStore_" "_" SYSTEM_KEY "${VCPKG_CMAKE_SYSTEM_NAME}_${VCPKG_TARGET_ARCHITECTURE}")
set(GETARCH_BINARY_DIR "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/${SYSTEM_KEY}")
if(EXISTS "${GETARCH_BINARY_DIR}")
    message(STATUS "OpenBLAS cross build, but may use ${PORT}:${HOST_TRIPLET} getarch")
    list(APPEND OPTIONS "-DGETARCH_BINARY_DIR=${GETARCH_BINARY_DIR}")
elseif(VCPKG_CROSSCOMPILING)
    message(STATUS "OpenBLAS cross build, may not be able to use getarch")
else()
    message(STATUS "OpenBLAS native build")
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    # Only the riscv64 kernel with riscv64_generic target is supported.
    # Cf. https://github.com/OpenMathLib/OpenBLAS/issues/3640#issuecomment-1144029630 et al.
    list(APPEND OPTIONS
        -DEMSCRIPTEN_SYSTEM_PROCESSOR=riscv64
        -DTARGET=RISCV64_GENERIC
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DCMAKE_POLICY_DEFAULT_CMP0054=NEW
        "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
        -DBUILD_TESTING=OFF
        -DBUILD_WITHOUT_LAPACK=ON
        -DNOFORTRAN=ON
    MAYBE_UNUSED_VARIABLES
        GETARCH_BINARY_DIR
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenBLAS)
vcpkg_fixup_pkgconfig()

# Required from native builds, optional from cross builds.
if(NOT VCPKG_CROSSCOMPILING OR EXISTS "${CURRENT_PACKAGES_DIR}/bin/getarch${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(
        TOOL_NAMES getarch getarch_2nd 
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/${SYSTEM_KEY}"
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
