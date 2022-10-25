# Note: upstream GitLab instance at https://graphics.rwth-aachen.de:9000 often goes down
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openmesh.org/media/Releases/${VERSION}/OpenMesh-${VERSION}.tar.gz"
    FILENAME "OpenMesh-${VERSION}.tar.gz"
    SHA512 d4d1872204595c8ccdf1fd09b2e923b7fc5e71e95958cbee52aeca0c1a3de0e648e4fa4913aca14acee30a000ef54b5abd92a30db8cef310e87bfbfe26726afc
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(OPENMESH_BUILD_SHARED ON)
else()
  set(OPENMESH_BUILD_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_APPS=OFF
        -DOPENMESH_BUILD_SHARED=${OPENMESH_BUILD_SHARED}
	MAYBE_UNUSED_VARIABLES
		OPENMESH_BUILD_SHARED
        # [TODO]: add apps as feature, requires qt5 and freeglut
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/OpenMesh/cmake)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/libdata/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  file(RENAME "${CURRENT_PACKAGES_DIR}/libdata/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/libdata" "${CURRENT_PACKAGES_DIR}/libdata")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/OpenMesh/Tools/VDPM/xpm")
# Only move dynamic libraries to bin on Windows
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/OpenMeshCore.dll" "${CURRENT_PACKAGES_DIR}/bin/OpenMeshCore.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/OpenMeshTools.dll" "${CURRENT_PACKAGES_DIR}/bin/OpenMeshTools.dll")
  endif()
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/OpenMeshCored.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/OpenMeshCored.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/OpenMeshToolsd.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/OpenMeshToolsd.dll")
  endif()
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/OpenMesh/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/OpenMesh")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
