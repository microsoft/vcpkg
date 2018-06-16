include(CMakeFindDependencyMacro)
find_dependency(SDL2 CONFIG)

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    find_dependency(PNG)
    if(@USE_JPEG@)
        find_dependency(JPEG)
    endif()
    if(@USE_TIFF@)
        find_dependency(TIFF)
    endif()
    # Disabled due to no webp find module available for consumers
    # if(@USE_WEBP@)
    #     find_dependency(WebP)
    # endif()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-sdl2-image-targets.cmake)
