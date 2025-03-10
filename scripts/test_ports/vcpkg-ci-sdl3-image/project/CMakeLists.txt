cmake_minimum_required(VERSION 3.30)
project(sdl3-image-test C CXX) # C++ for tiff[lerc]

block(SCOPE_FOR VARIABLES)
    find_package(SDL3_image CONFIG REQUIRED)

    add_executable(main main.c)
    target_link_libraries(main PRIVATE
        $<IF:$<TARGET_EXISTS:SDL3_image::SDL3_image-shared>,SDL3_image::SDL3_image-shared,SDL3_image::SDL3_image-static>
    )
endblock()

block(SCOPE_FOR VARIABLES)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(PC_SDL3_IMAGE sdl3-image REQUIRED IMPORTED_TARGET)

    add_executable(main-pkconfig main.c)
    if(WIN32 AND NOT MINGW)
        target_link_libraries(main-pkconfig PRIVATE PkgConfig::PC_SDL3_IMAGE)
    else()
        # Use raw flags, avoid find_library
        target_compile_options(main-pkconfig PRIVATE ${PC_SDL3_IMAGE_CFLAGS})
        target_link_libraries(main-pkconfig PRIVATE ${PC_SDL3_IMAGE_LDFLAGS})
    endif()
endblock()
