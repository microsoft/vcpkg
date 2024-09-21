# Note: upstream GitLab instance at https://graphics.rwth-aachen.de:9000 often goes down
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openmesh.org/media/Releases/${VERSION}/OpenMesh-${VERSION}.0.tar.gz"
    FILENAME "OpenMesh-${VERSION}.tar.gz"
    SHA512 b895e5eaabdf5d3671625df5314e1f95921ac672e9d9d945a5cf0973e20b4e395aac6517d86269a2e8c103f32bc9c8c2ecf57d811a260bbc69f592043e1307ba
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-library-install-path.patch
        fix-pkgconfig.patch

        # This patch is a combination of these two:
        # https://gitlab.vci.rwth-aachen.de:9000/OpenMesh/OpenMesh/-/commit/1d4a866282ace376c8e3ba05c21ce3bcc6643040
        # https://gitlab.vci.rwth-aachen.de:9000/OpenMesh/OpenMesh/-/commit/a7f30b6f70447932444f5b518840ca26e9461fa9
        restore-c++11-compatibility.patch
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
        -DVCI_COMMON_DO_NOT_COPY_POST_BUILD=ON
        -DVCI_NO_LIBRARY_INSTALL=ON
        -DOPENMESH_BUILD_SHARED=${OPENMESH_BUILD_SHARED}
	MAYBE_UNUSED_VARIABLES
		OPENMESH_BUILD_SHARED
        # [TODO]: add apps as feature, requires qt5 and freeglut
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME OpenMesh CONFIG_PATH "share/OpenMesh/cmake")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/OpenMesh/Tools/VDPM/xpm")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
