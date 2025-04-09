cmake_minimum_required(VERSION 3.20)
project(find-libintl C)

set(OUTFILE "${CMAKE_CURRENT_BINARY_DIR}/detected_intl.cmake" CACHE FILEPATH "Where to store results")

find_package(Intl)
find_file(LIBINTL_H NAMES libintl.h PATHS ${Intl_INCLUDE_DIRS})

string(CONFIGURE [[
set(VCPKG_DETECTED_Intl_FOUND "@Intl_FOUND@")
set(VCPKG_DETECTED_Intl_IS_BUILT_IN "@Intl_IS_BUILT_IN@")
set(VCPKG_DETECTED_Intl_INCLUDE_DIRS "@Intl_INCLUDE_DIRS@")
set(VCPKG_DETECTED_LIBINTL_H "@LIBINTL_H@")
]] detected_intl @ONLY ESCAPE_QUOTES)

file(WRITE "${OUTFILE}" "${detected_intl}")
