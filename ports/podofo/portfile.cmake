# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/podofo-0.9.5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/podofo/podofo/0.9.5/podofo-0.9.5.tar.gz"
    FILENAME "podofo-0.9.5.tar.gz"
    SHA512 d13b30bfebc89b809173cd2251eed1f15dfa90abb58371bfdce875797d40663923571824ad2b0b1d97aa1be212bdbb710c3a0439bc05bed7022b8eb75ca74705
)
vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DPODOFO_BUILD_LIB_ONLY=1 -DPODOFO_BUILD_SHARED=1
    )
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DPODOFO_BUILD_LIB_ONLY=1 -DPODOFO_BUILD_STATIC=1
    )
endif()

vcpkg_install_cmake()

# Handle copyright
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/podofo)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/podofo/COPYING ${CURRENT_PACKAGES_DIR}/share/podofo/copyright)
