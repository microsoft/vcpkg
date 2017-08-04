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

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/install-cmake-modules-to-share.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLLVM_TARGETS_TO_BUILD=X86
        -DLLVM_INCLUDE_TOOLS=OFF
        -DLLVM_INCLUDE_UTILS=OFF
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF
        -DLLVM_TOOLS_INSTALL_DIR=tools
)

vcpkg_install_cmake()

# Remove extra copy of cmake modules and include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Remove one empty include subdirectory if it is indeed empty
file(GLOB MCANALYSISFILES ${CURRENT_PACKAGES_DIR}/include/llvm/MC/MCAnalysis/*)
if(NOT MCANALYSISFILES)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/llvm/MC/MCAnalysis)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/llvm RENAME copyright)
