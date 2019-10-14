project(inih)

set(SOURCES ini.c cpp/INIReader.cpp)
set(HEADERS ini.h cpp/INIReader.h)

add_library(inih ${SOURCES})

install(
    TARGETS inih
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include)
