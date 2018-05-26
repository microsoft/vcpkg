# CMAKE project for duktape
option(SOURCE_PATH   "Root directory.")

project (duktape)

file(GLOB_RECURSE DUKTAPE_SOURCES "${SOURCE_PATH}/src/*.c")
file(GLOB_RECURSE DUKTAPE_HEADERS "${SOURCE_PATH}/src/*.h")

if (BUILD_SHARED_LIBS)
    add_definitions(-DDUK_F_DLL_BUILD)
endif ()

add_library(duktape ${DUKTAPE_SOURCES} ${DUKTAPE_HEADERS})

set_target_properties("duktape" PROPERTIES PUBLIC_HEADER "${DUKTAPE_HEADERS}")

install(TARGETS duktape
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include")
