cmake_minimum_required(VERSION 3.5)
project(chm C)

add_library(chm src/lzx.c src/chm_lib.c)

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
