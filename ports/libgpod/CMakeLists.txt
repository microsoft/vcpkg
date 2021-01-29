cmake_minimum_required (VERSION 3.12)

project (libgpod C)

option(WITH_INTERNAL_GCHECKSUM OFF)

find_package(unofficial-sqlite3 CONFIG REQUIRED)

include(SelectLibraryConfigurations)
find_path(glib_PATH glib.h PATHS include)
find_library(glib_LIBRARY_RELEASE NAMES glib-2.0 PATHS lib)
find_library(glib_LIBRARY_DEBUG NAMES glib-2.0 PATHS debug/lib)
select_library_configurations(glib)
if (NOT glib_FOUND)
	message(FATAL_ERROR "glib not found.")
endif()

find_path(plist_PATH plist++.h PATH_SUFFIXES plist)
find_library(plist_LIBRARY_RELEASE NAMES plist plist-2.0 libplist libplist-2.0 PATHS lib)
find_library(plist_LIBRARY_DEBUG NAMES plist plist-2.0 libplist libplist-2.0 PATHS debug/lib)
select_library_configurations(plist)
if (NOT plist_FOUND)
	message(FATAL_ERROR "plist not found.")
endif()
message("plist_PATH: ${plist_PATH}")

list(APPEND libgpod_Sources
	${CMAKE_CURRENT_SOURCE_DIR}/src/db-artwork-debug.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/db-artwork-parser.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/db-artwork-writer.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/db-image-parser.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/db-parse-context.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/gchecksum.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_artwork.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_chapterdata.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_device.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_hash58.c 
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_hash72.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_hashAB.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_iphone.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_itunesdb.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_photoalbum.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_playlist.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_plist.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_sqlite.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_sysinfo_extended_parser.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_thumb.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_track.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_tzinfo.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/itdb_zlib.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/ithumb-writer.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/pixmaps.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/rijndael.c
)

if (NOT WITH_INTERNAL_GCHECKSUM)
	list(REMOVE_ITEM libgpod_Sources ${CMAKE_CURRENT_SOURCE_DIR}/src/gchecksum.c)
endif()

add_library(libgpod ${libgpod_Sources})

target_include_directories(libgpod PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src ${glib_PATH} ${plist_PATH})

if (WITH_INTERNAL_GCHECKSUM)
	target_compile_definitions(libgpod PRIVATE -DWITH_INTERNAL_GCHECKSUM)
endif()
target_compile_definitions(libgpod PRIVATE -DLIBGPOD_BLOB_DIR=\"${LIBGPOD_BLOB_DIR}\" -DGETTEXT_PACKAGE="libgpod")

target_link_libraries(libgpod PRIVATE ${glib_LIBRARY} ${plist_LIBRARY} unofficial::sqlite3::sqlite3)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/itdb.h DESTINATION include/libgpod/gpod)

install(
  TARGETS libgpod
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)