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

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/embree-2.16.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/embree/embree/archive/v2.16.4.zip"
    FILENAME "embree-2.16.4.zip"
    SHA512 d26d31c7866c072d562dd824af02c90a1bc0302a2765fa6101925956f9b61870e45a4f0a54edae87d07a63aa4687f4244e3e5554491729ea31b617e87d02fb11
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-find-tbb.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_RUNTIME=OFF # use /MD and /MDd
        -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR} #  embree find TBB is not able to find tbb
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

# just wait, the release build of embree is insanely slow in MSVC
# a single file will took about 2-10 min
vcpkg_install_cmake()
vcpkg_copy_pdbs()

# these cmake files do not seem to contain helpful configuration for find libs, just remove them
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/embree-config.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/embree-config-version.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/embree-config.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/embree-config-version.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/models)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/models)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/embree)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/doc ${CURRENT_PACKAGES_DIR}/share/embree/doc)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/embree)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/embree/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/embree/copyright)
