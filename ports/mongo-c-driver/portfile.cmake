include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet. Portfile not modified and blocked by libbson.")
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mongo-c-driver-1.4.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/mongo-c-driver/releases/download/1.4.2/mongo-c-driver-1.4.2.tar.gz"
    FILENAME "mongo-c-driver-1.4.2.tar.gz"
    SHA512 402b9d0f2ae957a07336c9a6d971440472acef8e17a3ba5e89635ca454a13d4b7cf5f9b71151ed6182c012efb5fac6684acfc00443c6bca07cdd04b9f7eddaeb
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DBSON_ROOT_DIR=${CURRENT_INSTALLED_DIR}
)

vcpkg_build_cmake()
vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/COPYING ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/copyright)