set(VERSION 8.0)

# Note: upstream GitLab instance at https://graphics.rwth-aachen.de:9000 often goes down
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openmesh.org/media/Releases/${VERSION}/OpenMesh-${VERSION}.tar.gz"
    FILENAME "OpenMesh-${VERSION}.tar.gz"
    SHA512 6c9cb323d83d48daca7ddefe51df67f611befd657655d8013c2c620ad53e0b8521e6b8e25ebf3f5321f94182252ae0c75795875ff7ac11585e4ffa79e16f8008
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
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS 
        -DBUILD_APPS=OFF
        -DOPENMESH_BUILD_SHARED=${OPENMESH_BUILD_SHARED}
        # [TODO]: add apps as feature, requires qt5 and freeglut
        # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/OpenMesh/Tools/VDPM/xpm)
# Only move dynamic libraries to bin on Windows
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/OpenMeshCore.dll ${CURRENT_PACKAGES_DIR}/bin/OpenMeshCore.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/OpenMeshTools.dll ${CURRENT_PACKAGES_DIR}/bin/OpenMeshTools.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/OpenMeshCored.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMeshCored.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/OpenMeshToolsd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMeshToolsd.dll)
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
