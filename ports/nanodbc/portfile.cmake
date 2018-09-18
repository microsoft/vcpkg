if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/nanodbc-2.12.4)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nanodbc/nanodbc/archive/v2.12.4.tar.gz"
    FILENAME "nanodbc-2.12.4.tar.gz"
    SHA512 b9a924516b2a777e5f1497774997672320548722ed53413b0a7ad5d503e2f8ca1099f5059a912b7aae410928f4c4edcdfd02e4cfbf415976cd222697b354b4e6
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
		${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
		${CMAKE_CURRENT_LIST_DIR}/0002_msvc14_codecvt.patch
		${CMAKE_CURRENT_LIST_DIR}/0003_export_def.patch
		${CMAKE_CURRENT_LIST_DIR}/0004_unicode.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DNANODBC_EXAMPLES=OFF
		-DNANODBC_TEST=OFF
		-DNANODBC_USE_UNICODE=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nanodbc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nanodbc/LICENSE ${CURRENT_PACKAGES_DIR}/share/nanodbc/copyright)