# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/metis-5.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz"
    FILENAME "metis-5.1.0.tar.gz"
    SHA512 deea47749d13bd06fbeaf98a53c6c0b61603ddc17a43dae81d72c8015576f6495fd83c11b0ef68d024879ed5415c14ebdbd87ce49c181bdac680573bea8bdb25
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/enable-install.patch
        ${CMAKE_CURRENT_LIST_DIR}/disable-programs.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-runtime-install-destination.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-metis-vs14-math.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-gklib-vs14-math.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(OPTIONS -DSHARED=ON -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON)
else()
  set(OPTIONS -DSHARED=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/metis)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/metis/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/metis/copyright)
