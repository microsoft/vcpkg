include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mongo-cxx-driver-r3.1.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/mongo-cxx-driver/archive/r3.1.0.tar.gz"
    FILENAME "mongo-cxx-driver-r3.1.0.tar.gz"
    SHA512 2c9323f5e28304057b6ed6fc8bf33aad14db1313e234eaa74a96fb4cf93e99d24fd8c7c3f20b4b29cda7b1fe5c58f08dcb5cddcffbf62259c08334312fda4fba
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
		${CMAKE_CURRENT_LIST_DIR}/disable_test_and_example.patch
		${CMAKE_CURRENT_LIST_DIR}/disable_shared.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DLIBBSON_DIR=${CURRENT_INSTALLED_DIR}
		-DLIBMONGOC_DIR=${CURRENT_INSTALLED_DIR}
		-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON
)

vcpkg_install_cmake()

file(RENAME
	${CURRENT_PACKAGES_DIR}/include/bsoncxx/v_noabi/bsoncxx
	${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/bsoncxx)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include/bsoncxx)

file(RENAME
	${CURRENT_PACKAGES_DIR}/include/mongocxx/v_noabi/mongocxx
	${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/mongocxx)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include/mongocxx)

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/lib/cmake
	${CURRENT_PACKAGES_DIR}/debug/lib/cmake
	
	${CURRENT_PACKAGES_DIR}/include/bsoncxx/cmake
	${CURRENT_PACKAGES_DIR}/include/bsoncxx/config/private
	${CURRENT_PACKAGES_DIR}/include/bsoncxx/private
	${CURRENT_PACKAGES_DIR}/include/bsoncxx/test
	${CURRENT_PACKAGES_DIR}/include/bsoncxx/third_party
	
	${CURRENT_PACKAGES_DIR}/include/mongocxx/cmake
	${CURRENT_PACKAGES_DIR}/include/mongocxx/config/private
	${CURRENT_PACKAGES_DIR}/include/mongocxx/test
	${CURRENT_PACKAGES_DIR}/include/mongocxx/test_util
	${CURRENT_PACKAGES_DIR}/include/mongocxx/private
	${CURRENT_PACKAGES_DIR}/include/mongocxx/exception/private
	${CURRENT_PACKAGES_DIR}/include/mongocxx/options
	
	${CURRENT_PACKAGES_DIR}/debug/include)


if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/bsoncxx.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/bsoncxx.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/mongocxx.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/mongocxx.lib)
	
	file(RENAME
		${CURRENT_PACKAGES_DIR}/lib/libbsoncxx.lib
		${CURRENT_PACKAGES_DIR}/lib/bsoncxx.lib)
	file(RENAME
		${CURRENT_PACKAGES_DIR}/debug/lib/libmongocxx.lib
		${CURRENT_PACKAGES_DIR}/debug/lib/mongocxx.lib)
	
	# define MONGOCXX_STATIC in config/export.hpp
	vcpkg_apply_patches(
		SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
		PATCHES
			${CMAKE_CURRENT_LIST_DIR}/static.patch
	)
else()
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/libbsoncxx.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/libbsoncxx.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/libmongocxx.lib)
	file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/libmongocxx.lib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver RENAME copyright)