cmake_minimum_required(VERSION 3.11)
project(fontconfig C)

add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS -DHAVE_CONFIG_H)

# find dependencies
find_package(unofficial-iconv CONFIG REQUIRED)
find_package(Freetype REQUIRED)
find_package(EXPAT REQUIRED)

add_library(fontconfig
    src/fcatomic.c
    src/fcblanks.c
    src/fccache.c
    src/fccfg.c
    src/fccharset.c
    src/fccompat.c
    src/fcdbg.c
    src/fcdefault.c
    src/fcdir.c
    src/fcformat.c
    src/fcfreetype.c
    src/fcfs.c
    src/fcinit.c
    src/fclang.c
    src/fclist.c
    src/fcmatch.c
    src/fcmatrix.c
    src/fcname.c
    src/fcobjs.c
    src/fcpat.c
    src/fcrange.c
    src/fcserialize.c
    src/fcstat.c
    src/fcstr.c
    src/fcweight.c
    src/fcxml.c
    src/ftglue.c)

if(WIN32)
    set_target_properties(fontconfig PROPERTIES DEFINE_SYMBOL "FcPublic=__declspec(dllexport)")
else()
    set_target_properties(fontconfig PROPERTIES DEFINE_SYMBOL "FcPublic=__attribute__((visibility(\"default\")))")
endif()

target_include_directories(fontconfig PRIVATE .
    ${FC_INCLUDE_DIR}/alias ${EXPAT_INCLUDE_DIRS})
if(WIN32)
    target_include_directories(fontconfig PRIVATE ${FC_INCLUDE_DIR}/win32)
else()
    target_include_directories(fontconfig PRIVATE ${FC_INCLUDE_DIR}/unix)
endif()

#There is a strange behavior in CMake that if a target sets IMPORTED_LINK_INTERFACE_LANGUAGES to "C" the IMPORTED_LOCATION cannot contain a generator expression. 
#Thats why EXPAT here is not linked via the target but directly with the libraries.
target_link_libraries(fontconfig PRIVATE unofficial::iconv::libiconv Freetype::Freetype ${EXPAT_LIBRARIES})

install(TARGETS fontconfig
    EXPORT fontconfig-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

if(NOT FC_SKIP_HEADERS)
    install(FILES
        fontconfig/fontconfig.h
        fontconfig/fcfreetype.h
        fontconfig/fcprivate.h
        DESTINATION include/fontconfig)
endif()

if(NOT FC_SKIP_TOOLS)
    set(FC_DEFAULT_FONTS WINDOWSFONTDIR)
    set(FC_FONTPATH)
    set(FC_CACHEDIR WINDOWSTEMPDIR_FONTCONFIG_CACHE)
    set(CONFIGDIR ./fonts/conf.d)
    configure_file(fonts.conf.in ${CMAKE_SOURCE_DIR}/fonts.conf @ONLY)
    install(FILES fonts.conf DESTINATION tools/fontconfig/fonts)
    install(DIRECTORY conf.d DESTINATION tools/fontconfig/fonts FILES_MATCHING PATTERN "*.conf")
endif()

install(
    EXPORT fontconfig-targets
    NAMESPACE unofficial::fontconfig::
    FILE unofficial-fontconfig-targets.cmake
    DESTINATION share/unofficial-fontconfig
)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/unofficial-fontconfig-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(unofficial-iconv CONFIG)
find_dependency(Freetype)
find_dependency(EXPAT)

include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-fontconfig-targets.cmake)
")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-fontconfig-config.cmake DESTINATION share/unofficial-fontconfig)
