cmake_minimum_required(VERSION 3.8)

project(gmime C)

set(GMIME_DLL_SUFFIX 3)
set(GMIME_LIB_SUFFIX 3.0)

find_package(ZLIB REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB2 glib-2.0 gobject-2.0 gmodule-2.0 gio-2.0 IMPORTED_TARGET)
find_package(Iconv REQUIRED)

find_library(IDN_LIBRARY NAMES libidn2)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
endif()

add_definitions(-DHAVE_CONFIG_H)
add_definitions(-DG_DISABLE_DEPRECATED)
add_definitions(-DG_LOG_DOMAIN="GMime")

# Source files
file(GLOB LIB_SRC gmime/gmime-*.c)
list(APPEND LIB_SRC gmime/gmime.c
                    gmime/internet-address.c
                    util/packed.c
                    util/url-scanner.c
                    util/gtrie.c)

# Headers
file(GLOB LIB_HEADERS gmime/gmime-*.h)
list(APPEND LIB_HEADERS gmime/gmime.h)
list(APPEND LIB_HEADERS gmime/internet-address.h)

if(MSVC AND BUILD_SHARED_LIBS)
    set(MSVC_SRC gmime.def)
endif()

add_library(${PROJECT_NAME} ${LIB_SRC} ${MSVC_SRC})

set_target_properties(${PROJECT_NAME} PROPERTIES 
    OUTPUT_NAME ${PROJECT_NAME}-${GMIME_DLL_SUFFIX}
    ARCHIVE_OUTPUT_NAME ${PROJECT_NAME}-${GMIME_LIB_SUFFIX}
)

target_include_directories(${PROJECT_NAME} PRIVATE . ./util)
target_link_libraries(${PROJECT_NAME} PRIVATE Iconv::Iconv ZLIB::ZLIB ${IDN_LIBRARY})
target_link_libraries(${PROJECT_NAME} PRIVATE PkgConfig::GLIB2)
target_link_libraries(${PROJECT_NAME} PRIVATE Ws2_32.lib)

install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(FILES ${LIB_HEADERS} DESTINATION include/gmime)
