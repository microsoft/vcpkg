# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

# LLVM documentation recommends always using static library linkage when
#   building with Microsoft toolchain; it's also the default on other platforms
set(VCPKG_LIBRARY_LINKAGE static)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/llvm-4.0.0.src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://releases.llvm.org/4.0.0/llvm-4.0.0.src.tar.xz"
    FILENAME "llvm-4.0.0.src.tar.xz"
    SHA512 cf681f0626ef6d568d951cdc3e143471a1d7715a0ba11e52aa273cf5d8d421e1357ef2645cc85879eaefcd577e99e74d07b01566825b3d0461171ef2cbfc7704
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLLVM_TARGETS_TO_BUILD=X86
        -DLLVM_BUILD_TOOLS=OFF
        -DLLVM_BUILD_UTILS=OFF
        -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF
)

vcpkg_install_cmake()

# Move cmake modules to correct vcpkg location and remove extra copy
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/llvm DESTINATION ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# Remove extra copies of include files in debug directory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Remove bin directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

# Remove one empty include subdirectory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/llvm/MC/MCAnalysis)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/llvm)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/llvm/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/llvm/copyright)
