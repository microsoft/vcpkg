include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mongo-c-driver-1.5.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/mongo-c-driver/archive/1.5.1.tar.gz"
    FILENAME "mongo-c-driver-1.5.1.tar.gz"
    SHA512 2977e6e1fb3c45256161d2c9bd711fea69b9f8c9ff15362fa636068e0a347c42e10d72fed5649504b552c8212f21cb1ae74d2dc8ca3d1388f49e63b2baf6e16d
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DBSON_ROOT_DIR=${CURRENT_INSTALLED_DIR}
		-DENABLE_TESTS=OFF
		-DENABLE_EXAMPLES=OFF
		-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON
)

vcpkg_install_cmake()

file(RENAME
	${CURRENT_PACKAGES_DIR}/include/libmongoc-1.0
	${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/mongoc-1.0.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-1.0.lib)
	
	file(RENAME
		${CURRENT_PACKAGES_DIR}/lib/mongoc-static-1.0.lib
		${CURRENT_PACKAGES_DIR}/lib/mongoc-1.0.lib)
	file(RENAME
		${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-static-1.0.lib
		${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-1.0.lib)
else()
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/mongoc-static-1.0.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/mongoc-static-1.0.lib)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver RENAME copyright)