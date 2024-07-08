if(VCPKG_TARGET_IS_WINDOWS)
    # https://github.com/llvm/llvm-project/blob/llvmorg-18.1.6/openmp/runtime/CMakeLists.txt#L331
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/openmp-${VERSION}.src.tar.xz"
    FILENAME "llvm-openmp-${VERSION}.src.tar.xz"
    SHA512 7c2ca736524fb741112be247ac6be39cfe1dc92381c5e2997d97044ab9705c224ae5eabcf43b59cdec9a715a14227c6fb02cb2d1829ebc47b82d3af6e4d197d3
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-disable-libomp-aliases.patch
        0002-disable-tests.patch
        0004-install-config.patch
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/cmake-${VERSION}.src.tar.xz"
    FILENAME "llvm-cmake-${VERSION}.src.tar.xz"
    SHA512 e02243b491f9e688db28d7b53270fcf87debf09d3c95b136a7c7b96e26890de68712c60a1e85f5a448a95ad8c81f2d8ae77047780822443bbe39f1a9e6211007
)
vcpkg_extract_source_archive(CMAKE_SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)
file(GLOB_RECURSE CMAKE_MODULES "${CMAKE_SOURCE_PATH}/*.cmake")
file(COPY ${CMAKE_MODULES} DESTINATION "${SOURCE_PATH}/cmake")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/llvm-openmp-config.cmake.in" DESTINATION "${SOURCE_PATH}/runtime/cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "shared" ENABLE_SHARED)
if(VCPKG_TARGET_IS_WINDOWS)
    set(ENABLE_SHARED ON)
endif()

# Perl is required for the OpenMP run-time
vcpkg_find_acquire_program(PERL)


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
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/debug/tools"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
