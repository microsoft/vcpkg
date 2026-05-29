cmake_minimum_required(VERSION 3.14)
project(ecos C)

#include(GNUInstallDirs)

set(EXTERNAL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/external)

set(SUITESPARSE ${EXTERNAL_SRC}/SuiteSparse_config)
add_library(ecos-suitesparse INTERFACE)
target_sources(ecos-suitesparse INTERFACE $<BUILD_INTERFACE:${SUITESPARSE}/SuiteSparse_config.h> $<INSTALL_INTERFACE:include/ecos>)
target_include_directories(ecos-suitesparse INTERFACE $<BUILD_INTERFACE:${SUITESPARSE}> $<INSTALL_INTERFACE:include/ecos>)
target_compile_definitions(ecos-suitesparse INTERFACE DLONG LDL_LONG)

set(AMD_SRC ${EXTERNAL_SRC}/amd/src)
set(AMD_INCLUDE ${EXTERNAL_SRC}/amd/include)
add_library(ecos-amd STATIC
	${AMD_SRC}/amd_1.c ${AMD_SRC}/amd_2.c ${AMD_SRC}/amd_aat.c ${AMD_SRC}/amd_control.c ${AMD_SRC}/amd_defaults.c ${AMD_SRC}/amd_dump.c ${AMD_SRC}/amd_global.c ${AMD_SRC}/amd_info.c ${AMD_SRC}/amd_order.c ${AMD_SRC}/amd_post_tree.c ${AMD_SRC}/amd_postorder.c ${AMD_SRC}/amd_preprocess.c ${AMD_SRC}/amd_valid.c
)
file(GLOB AMD_HEADERS ${EXTERNAL_SRC}/amd/include/*.h)
target_include_directories(ecos-amd PUBLIC $<BUILD_INTERFACE:${AMD_INCLUDE}> $<INSTALL_INTERFACE:include/ecos>)
target_link_libraries(ecos-amd ecos-suitesparse)


add_library(ecos-ldl STATIC
	${EXTERNAL_SRC}/ldl/src/ldl.c
)
file(GLOB LDL_HEADERS ${EXTERNAL_SRC}/ldl/include/*.h)
target_include_directories(ecos-ldl PUBLIC $<BUILD_INTERFACE:${EXTERNAL_SRC}/ldl/include/> $<INSTALL_INTERFACE:include/ecos>)
target_link_libraries(ecos-ldl ecos-suitesparse)


add_library(ecos STATIC
	src/cone.c src/ecos.c src/expcone.c src/preproc.c src/splamm.c src/wright_omega.c src/ctrlc.c src/equil.c src/kkt.c src/spla.c src/timer.c 
)
file(GLOB ECOS_HEADERS include/*.h)
target_include_directories(ecos PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include/ecos>)
target_link_libraries(ecos ecos-amd ecos-ldl)

install(FILES ${SUITESPARSE}/SuiteSparse_config.h DESTINATION "include/ecos/")
install(FILES ${ECOS_HEADERS} DESTINATION "include/ecos/")
install(FILES ${LDL_HEADERS} DESTINATION "include/ecos/")
install(FILES ${AMD_HEADERS} DESTINATION "include/ecos/")

install(TARGETS ecos ecos-amd ecos-ldl ecos-suitesparse EXPORT ecos-targets)
install(
	EXPORT ecos-targets
	FILE ecos-config.cmake
	DESTINATION share/ecos/
)