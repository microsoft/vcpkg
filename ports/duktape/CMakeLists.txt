project (duktape)

file(GLOB_RECURSE DUKTAPE_SOURCES "src/*.c")
file(GLOB_RECURSE DUKTAPE_HEADERS "src/*.h")

if (BUILD_SHARED_LIBS)
    add_definitions(-DDUK_F_DLL_BUILD)
endif ()

include_directories("src/")

add_library(duktape ${DUKTAPE_SOURCES} ${DUKTAPE_HEADERS})

set_target_properties("duktape" PROPERTIES PUBLIC_HEADER "${DUKTAPE_HEADERS}")

install(TARGETS duktape
        EXPORT duktape-targets
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include")

