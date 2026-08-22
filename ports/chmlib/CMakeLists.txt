cmake_minimum_required(VERSION 3.5)
project(chm C)

include (CheckIncludeFiles)
check_include_files(strings.h HAVE_STRINGS_H) # for ffs

add_library(chm src/lzx.c src/chm_lib.c)
if(HAVE_STRINGS_H)
    target_compile_definitions(chm PRIVATE CHMLIB_HAVE_STRINGS_H)
endif()

if(BUILD_TOOLS)
    link_libraries(chm)
    add_executable(enum_chmLib src/enum_chmLib.c)
    add_executable(enumdir_chmLib src/enumdir_chmLib.c)
    add_executable(extract_chmLib src/extract_chmLib.c)

    install(TARGETS enum_chmLib extract_chmLib enumdir_chmLib
        RUNTIME DESTINATION tools/chmlib
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )
endif()

install(TARGETS chm
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
