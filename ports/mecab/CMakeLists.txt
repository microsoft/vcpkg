cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

PROJECT(Mecab)
                          
file(GLOB SOURCE_FILE
	"*.cpp"
	"*.c"
)
file(GLOB HEADERS_FILE
	"*.h"
)

message(STATUS "current cmake path: ${CMAKE_CURRENT_SOURCE_DIR}")
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-cost-train.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-dict-gen.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-dict-index.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-system-eval.cpp)
list(REMOVE_ITEM SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mecab-test-gen.cpp)
#list(REMOVE_ITEM SOURCE_FILE "mecab-cost-train.cpp" "mecab-dict-gen.cpp" "mecab-dict-index.cpp" "mecab-system-eval.cpp" "mecab-test-gen.cpp")

add_library (Mecab ${SOURCE_FILE} ${HEADERS_FILE})

if(UNIX)
	target_compile_definitions(Mecab PUBLIC -DHAVE_UNISTD_H -DHAVE_FCNTL_H -DHAVE_STDINT_H -DHAVE_SYS_TYPES_H -DHAVE_SYS_STAT_H -DHAVE_DIRENT_H -DDIC_VERSION=102 -DVERSION="@VERSION@" -DPACKAGE="mecab" -DMECAB_DEFAULT_RC="./mecabrc")
endif(UNIX)
if(WIN32)
	target_compile_definitions(Mecab PUBLIC -D_CRT_SECURE_NO_DEPRECATE -DMECAB_USE_THREAD -DDLL_EXPORT -DHAVE_GETENV -DHAVE_WINDOWS_H -DDIC_VERSION=102 -DVERSION="@VERSION@" -DPACKAGE="mecab" -DUNICODE -D_UNICODE -DMECAB_DEFAULT_RC="mecabrc")
endif(WIN32)

install(TARGETS Mecab
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
include(CMakePackageConfigHelpers)
set(cmake_package_name Mecab)
set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated" CACHE INTERNAL "")
set(cmake_files_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${cmake_package_name}")
set(config_file "${generated_dir}/${cmake_package_name}Config.cmake")
configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in"
"${config_file}" INSTALL_DESTINATION ${cmake_files_install_dir})
#install(FILES ${config_file} DESTINATION ${cmake_files_install_dir} CONFIGURATIONS Release)
install(FILES ${config_file} DESTINATION share/mecab CONFIGURATIONS Release)
message(STATUS "ccmake_files_install_dir: ${cmake_files_install_dir}")

install(FILES ${HEADERS_FILE} DESTINATION include CONFIGURATIONS Release)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)