# CMAKE project for duktape
option(SOURCE_PATH   "Root directory.")
option(ENABLE_STATIC "Build a static library.")

set (PROJECT duktape)
project (${PROJECT})

file(GLOB_RECURSE DUKTAPE_SOURCES "${SOURCE_PATH}/src/*.c")
file(GLOB_RECURSE DUKTAPE_HEADERS "${SOURCE_PATH}/src/*.h")

if (ENABLE_STATIC)
    add_library(${PROJECT} STATIC ${DUKTAPE_SOURCES} ${DUKTAPE_HEADERS})
else ()
    add_definitions(-DDUK_F_DLL_BUILD)
    add_library(${PROJECT} SHARED ${DUKTAPE_SOURCES})
endif ()

set_target_properties(${PROJECT} PROPERTIES PUBLIC_HEADER "${DUKTAPE_HEADERS}")

install(TARGETS ${PROJECT}
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include")
