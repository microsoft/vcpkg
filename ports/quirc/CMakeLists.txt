cmake_minimum_required(VERSION 2.8)

project(quirc C)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(quirc
	lib/decode.c
	lib/identify.c
	lib/quirc.c
	lib/version_db.c
)

install(TARGETS quirc
		RUNTIME DESTINATION bin
		ARCHIVE DESTINATION lib
		LIBRARY DESTINATION lib)

install(FILES ${PROJECT_SOURCE_DIR}/lib/quirc.h DESTINATION include)
