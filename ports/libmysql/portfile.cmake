include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mysql-server-mysql-5.7.16)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mysql/mysql-server/archive/mysql-5.7.16.tar.gz"
    FILENAME "mysql-server-mysql-5.7.16.tar.gz"
    SHA512 30a3c55ebb15f18ededf814b66c108f18b2ced9c39e08319cdc9559ccf38d494ad9322098f2b04418ddf557e46d9d727be0e514be0ae982ac4f5186aa295b9c6
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
		${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# delete debug headers
file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include)

# delete useless vcruntime/scripts/bin/msg file
file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/share
	${CURRENT_PACKAGES_DIR}/debug/share
	${CURRENT_PACKAGES_DIR}/bin
	${CURRENT_PACKAGES_DIR}/debug/bin)

file(MAKE_DIRECTORY
	${CURRENT_PACKAGES_DIR}/share
	${CURRENT_PACKAGES_DIR}/debug/share
	${CURRENT_PACKAGES_DIR}/bin
	${CURRENT_PACKAGES_DIR}/debug/bin)

# remove misc files
file(REMOVE
	${CURRENT_PACKAGES_DIR}/COPYING
	${CURRENT_PACKAGES_DIR}/my-default.ini
	${CURRENT_PACKAGES_DIR}/README
	${CURRENT_PACKAGES_DIR}/debug/COPYING
	${CURRENT_PACKAGES_DIR}/debug/my-default.ini
	${CURRENT_PACKAGES_DIR}/debug/README)

# correct the dll directory
file (RENAME ${CURRENT_PACKAGES_DIR}/lib/libmysql.dll ${CURRENT_PACKAGES_DIR}/bin/libmysql.dll)
file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.dll ${CURRENT_PACKAGES_DIR}/debug/libmysql.dll)

# copy license
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmysql)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmysql/COPYING ${CURRENT_PACKAGES_DIR}/share/libmysql/copyright)