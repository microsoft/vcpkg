#

set(CORRADE_HASH b87c50db3543367b6eb20dc72246c6687449b029)

include(vcpkg_common_functions)


set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/corrade-${CORRADE_HASH})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mosra/corrade/archive/${CORRADE_HASH}.zip"
    FILENAME "corrade-${CORRADE_HASH}.zip"
    SHA512 b15b544f996b8c95fbdf73ff9b76deea465fdcf06f431b09f4bbb9a786f4e864fdb4f8c5a2977cb366ee2398c54eac4c469da29c2ab7c67d3b8f7cbf7d2120dc
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC 1)
else()
    set(BUILD_STATIC 0)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_STATIC=${BUILD_STATIC}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Drop a copy of tools
file(COPY ${CURRENT_PACKAGES_DIR}/bin/corrade-rc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/)
# Tools require dlls
file(GLOB TO_COPY
   ${CURRENT_PACKAGES_DIR}/bin/*.dll)
file(COPY ${TO_COPY} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/)

file(GLOB_RECURSE TO_REMOVE 
   ${CURRENT_PACKAGES_DIR}/bin/*.exe
   ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${TO_REMOVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/corrade)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/corrade/COPYING ${CURRENT_PACKAGES_DIR}/share/corrade/copyright)

vcpkg_copy_pdbs()