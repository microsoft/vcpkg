cmake_minimum_required(VERSION 3.0)
project(SDL2-gfx VERSION 1.0.4 LANGUAGES C)

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)

# builtin formats
set(SDL_GFX_DEFINES WIN32)
if(BUILD_SHARED_LIBS)
    list(APPEND SDL_GFX_DEFINES DLL_EXPORT)
endif()

add_library(${PROJECT_NAME}
    SDL2_framerate.c
    SDL2_gfxPrimitives.c
    SDL2_imageFilter.c
    SDL2_rotozoom.c)

target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include/SDL2>
)

target_compile_definitions(${PROJECT_NAME} PRIVATE ${SDL_GFX_DEFINES})
target_include_directories(${PROJECT_NAME} PRIVATE ${SDL_INCLUDE_DIR}/SDL2)
target_link_libraries(${PROJECT_NAME} PRIVATE SDL2::SDL2)

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_Targets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if (WINDOWS)
  set(PKG_PREFIX "cmake")
else ()
  set(PKG_PREFIX "lib/cmake/${PROJECT_NAME}")
endif ()

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in"
    "${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION ${PKG_PREFIX}
)

install(EXPORT ${PROJECT_NAME}_Targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${PKG_PREFIX}
)

install(FILES "${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
              "${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        DESTINATION ${PKG_PREFIX}
)

if(NOT SDL_GFX_SKIP_HEADERS)
    install(FILES SDL2_framerate.h SDL2_gfxPrimitives.h SDL2_imageFilter.h SDL2_rotozoom.h SDL2_gfxPrimitives_font.h DESTINATION include/SDL2)
endif()
