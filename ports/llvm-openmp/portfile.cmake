vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/openmp-${VERSION}.src.tar.xz"
    FILENAME "llvm-openmp-${VERSION}.src.tar.xz"
    SHA512 f96f5fd4c508f1390e53b943237aa7e1db1301ef660f0864305556d581275576d585ef222a82d2359d43ad8ed166096d9ec6c05ab0ee57a01679cff6b4ecba4b
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-disable-libomp-aliases.patch
        0002-disable-tests.patch
        0003-fix-windows-import-lib-name.patch
        0004-install-config.patch
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/cmake-${VERSION}.src.tar.xz"
    FILENAME "llvm-cmake-${VERSION}.src.tar.xz"
    SHA512 1334647f4be280b41858aa272bebc65e935cab772001032f77040396ba7472fbd5eb6a1a0c042ab7156540075705b7f05c8de2f02e2ce9d7ec1ec27be6bef86f
)
vcpkg_extract_source_archive(CMAKE_SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)
file(GLOB_RECURSE CMAKE_MODULES "${CMAKE_SOURCE_PATH}/*.cmake")
file(COPY ${CMAKE_MODULES} DESTINATION "${SOURCE_PATH}/cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "shared" ENABLE_SHARED)

# Perl is required for the OpenMP run-time
vcpkg_find_acquire_program(PERL)

if(VCPKG_HOST_IS_WINDOWS)
    # The library name otherwise includes a "lib" prefix on Windows, which is inconsistent with other platforms.
    set(EXTRA_VARS -DLIBOMP_LIB_NAME=omp)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPENMP_STANDALONE_BUILD=ON
        -DLIBOMP_ENABLE_SHARED=${ENABLE_SHARED}
        -DLIBOMP_INSTALL_ALIASES=OFF
        -DOPENMP_ENABLE_LIBOMPTARGET=OFF # Currently libomptarget cannot be compiled on Windows or MacOS X.
        -DOPENMP_ENABLE_OMPT_TOOLS=OFF # Currently tools are not tested well on Windows or MacOS X.
        -DLIBOMP_OMPT_SUPPORT=OFF
        -DLLVM_OPENMP_VERSION=${VERSION}
        -DPERL_EXECUTABLE=${PERL}
        ${EXTRA_VARS}
)

vcpkg_cmake_install()

# llvm-openmp has hardcoded its OMP runtime version since v9
# https://github.com/llvm/llvm-project/commit/e4b4f994d2f6a090694276b40d433dc1a58beb24
set(OpenMP_VERSION 5.0)
set(OpenMP_VERSION_MAJOR 5)
set(OpenMP_VERSION_MINOR 0)
set(OpenMP_SPEC_DATE 201611)
configure_file("${CMAKE_CURRENT_LIST_DIR}/FindOpenMP.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/FindOpenMP.cmake" @ONLY)

# Remove debug headers and tools
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/debug/tools"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
