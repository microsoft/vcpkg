include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mariadb-connector-c-2.3.1)

if (EXISTS "${CURRENT_INSTALLED_DIR}/include/mysql.h")
	message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/MariaDB/mariadb-connector-c/archive/v2.3.1.tar.gz"
    FILENAME "mariadb-connector-c-2.3.1.tar.gz"
    SHA512 d82f8348201d41dce6820c952a0503a5154c4e9c06feb471fe451a6fb968e5cff04423a64183cbb8e159a1b4e7265c12b5b7aef912f633395d9f1b0436fbfd2d
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_build_cmake()
vcpkg_install_cmake()

# remove debug header
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# fix libmariadb lib & dll directory.
file(MAKE_DIRECTORY 
	${CURRENT_PACKAGES_DIR}/bin
	${CURRENT_PACKAGES_DIR}/debug/bin)
file(RENAME 
	${CURRENT_PACKAGES_DIR}/lib/mariadb/libmariadb.dll 
	${CURRENT_PACKAGES_DIR}/bin/libmariadb.dll)
file(RENAME 
	${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/libmariadb.dll 
	${CURRENT_PACKAGES_DIR}/debug/bin/libmariadb.dll)
file(RENAME 
	${CURRENT_PACKAGES_DIR}/lib/mariadb/libmariadb.lib 
	${CURRENT_PACKAGES_DIR}/lib/libmariadb.lib)
file(RENAME 
	${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/libmariadb.lib 
	${CURRENT_PACKAGES_DIR}/debug/lib/libmariadb.lib)
file(REMOVE 
	${CURRENT_PACKAGES_DIR}/lib/mariadb/mariadbclient.lib
	${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/mariadbclient.lib)

# remove plugin folder
file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/lib/plugin
	${CURRENT_PACKAGES_DIR}/debug/lib/plugin
	${CURRENT_PACKAGES_DIR}/lib/mariadb
	${CURRENT_PACKAGES_DIR}/debug/lib/mariadb)

# copy & remove header files
file(GLOB HEADER_FILES ${CURRENT_PACKAGES_DIR}/include/mariadb/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/mariadb)
file(REMOVE
	${CURRENT_PACKAGES_DIR}/include/config-win.h
	${CURRENT_PACKAGES_DIR}/include/dbug.h
	${CURRENT_PACKAGES_DIR}/include/errmsg.h
	${CURRENT_PACKAGES_DIR}/include/getopt.h
	${CURRENT_PACKAGES_DIR}/include/hash.h
	${CURRENT_PACKAGES_DIR}/include/ma_common.h
	${CURRENT_PACKAGES_DIR}/include/ma_dyncol.h
	${CURRENT_PACKAGES_DIR}/include/sha1.h
	${CURRENT_PACKAGES_DIR}/include/thr_alarm.h
	${CURRENT_PACKAGES_DIR}/include/violite.h
	${CURRENT_PACKAGES_DIR}/include/mysql_version.h.in
	${CURRENT_PACKAGES_DIR}/include/my_config.h.in
	${CURRENT_PACKAGES_DIR}/include/CMakeLists.txt
	${CURRENT_PACKAGES_DIR}/include/Makefile.am)

# copy license file
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmariadb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmariadb/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/libmariadb/copyright)