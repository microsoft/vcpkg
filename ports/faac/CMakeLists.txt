cmake_minimum_required(VERSION 3.7.2)
project (faac VERSION 1.30)

option(FAAC_BUILD_BINARIES "Build faac binaries" ON)

file(GLOB FAAC_SOURCES "${CMAKE_CURRENT_LIST_DIR}/libfaac/*.c")
file(GLOB FAAC_HEADERS "${CMAKE_CURRENT_LIST_DIR}/libfaac/*.h")

add_definitions(-DPACKAGE_VERSION=\"${PROJECT_VERSION}\" -D_CRT_SECURE_NO_WARNINGS -D_USE_MATH_DEFINES)

add_library(faac ${FAAC_SOURCES} ${FAAC_HEADERS})

target_include_directories(${PROJECT_NAME}
    PUBLIC
        "${CMAKE_CURRENT_LIST_DIR}/include"
)

if (BUILD_SHARED_LIBS)
    target_compile_definitions(faac PRIVATE FAACEXPORT)
endif ()

install(
    TARGETS faac
        ARCHIVE DESTINATION "lib"
        LIBRARY DESTINATION "lib"
        RUNTIME DESTINATION "bin"
    )

if (FAAC_BUILD_BINARIES)
    add_executable(faac_cli
        "${CMAKE_SOURCE_DIR}/frontend/input.c"
        "${CMAKE_SOURCE_DIR}/frontend/main.c"
        "${CMAKE_SOURCE_DIR}/frontend/mp4write.c"
    )
    target_include_directories(faac_cli
        PRIVATE
            "${CMAKE_CURRENT_LIST_DIR}/frontend"
            ${FAAC_HEADERS}
    )
    if (MSVC)
        target_include_directories(faac_cli
            PRIVATE
                "${CMAKE_CURRENT_LIST_DIR}/project/msvc"
        )
    endif ()
    target_link_libraries(faac_cli PRIVATE faac)

    install(
        TARGETS faac_cli
            RUNTIME DESTINATION "bin"
        )
endif ()
