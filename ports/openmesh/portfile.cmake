set(VERSION 8.1)

# Note: upstream GitLab instance at https://graphics.rwth-aachen.de:9000 often goes down
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openmesh.org/media/Releases/${VERSION}/OpenMesh-${VERSION}.tar.gz"
    FILENAME "OpenMesh-${VERSION}.tar.gz"
    SHA512 c146e6b21d709a31772621a6a913def93a51460c4abb950c2eb64eea4528c7efd4c86166ba56ae0bc8090cc5878dd9328b570e094e61c1b64d6d298de05aca61
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF "${VERSION}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(OPENMESH_BUILD_SHARED ON)
else()
  set(OPENMESH_BUILD_SHARED OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_APPS=OFF
        -DOPENMESH_BUILD_SHARED=${OPENMESH_BUILD_SHARED}
        # [TODO]: add apps as feature, requires qt5 and freeglut
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/OpenMesh/cmake TARGET_PATH share/OpenMesh/cmake)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/libdata/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  file(RENAME "${CURRENT_PACKAGES_DIR}/libdata/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/libdata" "${CURRENT_PACKAGES_DIR}/libdata")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/OpenMesh/Tools/VDPM/xpm)
# Only move dynamic libraries to bin on Windows
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/OpenMeshCore.dll ${CURRENT_PACKAGES_DIR}/bin/OpenMeshCore.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/OpenMeshTools.dll ${CURRENT_PACKAGES_DIR}/bin/OpenMeshTools.dll)
  endif()
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/OpenMeshCored.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMeshCored.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/OpenMeshToolsd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMeshToolsd.dll)
  endif()
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
