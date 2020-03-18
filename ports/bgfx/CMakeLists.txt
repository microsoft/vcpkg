
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
project(bx VERSION 2020.03.14.0 LANGUAGES C CXX)

include(GNUInstallDirs)

# dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads)

find_package(bx CONFIG REQUIRED)

if (BGFX_WITH_VULKAN OR BGFX_WITH_TOOLING)
    find_package(Vulkan REQUIRED)
endif()
if (BGFX_WITH_TOOLING OR BGFX_WITH_EXAMPLES)
    find_package(bimg CONFIG REQUIRED)
    find_package(freetype CONFIG REQUIRED)
endif()
if (BGFX_WITH_TOOLING)
    find_package(lodepng CONFIG REQUIRED)
    find_package(glslang CONFIG REQUIRED)

    find_package(spirv_cross_core CONFIG REQUIRED)
    find_package(spirv_cross_glsl CONFIG REQUIRED)
    find_package(spirv_cross_msl CONFIG REQUIRED)
    find_package(spirv_cross_reflect CONFIG REQUIRED)

    find_package(SPIRV-Tools CONFIG REQUIRED)
    find_package(SPIRV-Tools-opt CONFIG REQUIRED)
endif()


add_compile_definitions(_CRT_SECURE_NO_WARNINGS)

# bgfx library
add_library(bgfx)
add_library(bgfx::bgfx ALIAS bgfx)

target_sources(bgfx
    PRIVATE
        src/amalgamated.$<IF:$<PLATFORM_ID:Darwin>,mm,cpp>

    PUBLIC
        $<$<PLATFORM_ID:Windows>:$<INSTALL_INTERFACE:${CMAKE_INSTALL_DATADIR}/bgfx/bgfx.natvis>>
)

target_include_directories(bgfx
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>

    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/renderdoc>
)

target_compile_definitions(bgfx
    PRIVATE
        "BGFX_CONFIG_DEBUG=$<BOOL:${BGFX_CONFIG_DEBUG}>"
        "BGFX_CONFIG_USE_TINYSTL=0"
)

target_link_libraries(bgfx PUBLIC
    Bx::bx
)
if (BGFX_WITH_VULKAN)
    target_compile_definitions(bgfx PRIVATE BGFX_CONFIG_RENDERER_VULKAN=1)
    target_link_libraries(bgfx PUBLIC Vulkan::Vulkan)
endif()
if (BGFX_WITH_OPENGL)
    find_package(OpenGL REQUIRED)
    if (BGFX_WITH_OPENGL_CORE)
        set(BGFX_WITH_OPENGL 32)
    else()
        set(BGFX_WITH_OPENGL 1)
    endif()
    target_compile_definitions(bgfx PRIVATE BGFX_CONFIG_RENDERER_OPENGL=${BGFX_WITH_OPENGL})
endif()

if (WIN32)
    target_link_libraries(bgfx PUBLIC gdi32 psapi)

    if (BGFX_WITH_D3D11)
        target_compile_definitions(bgfx PRIVATE BGFX_CONFIG_RENDERER_DIRECT3D11=1)
    endif()
    if (BGFX_WITH_D3D12)
        target_compile_definitions(bgfx PRIVATE BGFX_CONFIG_RENDERER_DIRECT3D12=1)
    endif()
    if (BGFX_WITH_OPENGL)
        target_link_libraries(bgfx PUBLIC OpenGL::GL)
    endif()

elseif (APPLE)

    message(FATAL_ERROR "you must implement apple metal framework linking first.")

elseif (UNIX)

    if (BGFX_WITH_OPENGL)

        find_package(X11 REQUIRED)
        target_link_libraries(bgfx PUBLIC OpenGL::OpenGL)

        target_include_directories(bgfx PRIVATE ${X11_INCLUDE_DIR})
        target_link_libraries(bgfx PUBLIC ${X11_LIBRARIES} OpenGL::GLX)

    endif()

endif()

if (BGFX_WITH_TOOLING OR BGFX_WITH_EXAMPLES)
    # example-common (not installed directly, it is used only for building tools and examples)
    add_library(example-common STATIC)

    file(GLOB_RECURSE ECOMMON_SOURCES "examples/common/*.cpp")
    file(GLOB_RECURSE IMGUI_SOURCES "3rdparty/dear-imgui/*.cpp")
    file(GLOB_RECURSE MESHOPTIMIZER_SOURCES "3rdparty/meshoptimizer/src/*.cpp")

    target_sources(example-common PRIVATE
        ${ECOMMON_SOURCES}

        ${IMGUI_SOURCES}

        ${MESHOPTIMIZER_SOURCES}
    )

    target_include_directories(example-common
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty>

        INTERFACE
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/examples/common>
    )

    target_link_libraries(example-common PUBLIC
        Bx::bx
        Bx::compat
        Bimg::bimg
        Bimg::bimg_decode
        bgfx::bgfx

        freetype
    )
endif()

if (BGFX_WITH_TOOLING)
    # geometryv
    add_executable(geometryv)
    add_executable(bgfx::geometryv ALIAS geometryv)

    target_sources(geometryv PRIVATE tools/geometryv/geometryv.cpp)

    target_link_libraries(geometryv PRIVATE
        example-common
    )

    # texturev
    add_executable(texturev)
    add_executable(bgfx::texturev ALIAS texturev)

    target_sources(texturev PRIVATE tools/texturev/texturev.cpp)

    target_link_libraries(texturev PRIVATE
        example-common
    )

    # geometryc
    add_executable(geometryc)
    add_executable(bgfx::geometryc ALIAS geometryc)

    file(GLOB_RECURSE MESHOPTIMIZER_SOURCES "3rdparty/meshoptimizer/src/*.cpp")

    target_sources(geometryc PRIVATE
        tools/geometryc/geometryc.cpp
        src/vertexdecl.cpp
        examples/common/bounds.cpp

        ${MESHOPTIMIZER_SOURCES}
    )

    target_include_directories(geometryc PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/examples/common>
    )

    target_link_libraries(geometryc PRIVATE
        Bx::bx

        $<$<PLATFORM_ID:Windows>:psapi>
    )

    # frexx c preprocessor (not installed, only required for shaderc)
    add_library(fcpp STATIC)
    file(GLOB FCPP_SOURCES "3rdparty/fcpp/cpp?.c")
    target_sources(fcpp PRIVATE ${FCPP_SOURCES})
    target_include_directories(fcpp PUBLIC "3rdparty/fcpp")
    target_compile_definitions(fcpp PRIVATE
        "NINCLUDE=64"
        "NWORK=65536"
        "NBUFF=65536"
        "OLD_PREPROCESSOR=0"
    )

    # glsl-optimizer (not installed, only required for shaderc)
    add_library(glsl-optimizer STATIC)
    file(GLOB_RECURSE GLSL_OPTIMIZER_SOURCES
        "3rdparty/glsl-optimizer/src/glsl/*.cpp"
        "3rdparty/glsl-optimizer/src/glsl/*.c"
        "3rdparty/glsl-optimizer/src/mesa/*.c"
        "3rdparty/glsl-optimizer/src/util/*.c"
    )
    list(FILTER GLSL_OPTIMIZER_SOURCES EXCLUDE REGEX .*main\\.cpp)
    target_sources(glsl-optimizer PRIVATE ${GLSL_OPTIMIZER_SOURCES})
    target_include_directories(glsl-optimizer PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/glsl-optimizer/include"
        "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/glsl-optimizer/src"
        "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/glsl-optimizer/src/glsl"
        "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/glsl-optimizer/src/mesa"
    )
    if (MSVC)
        target_compile_options(glsl-optimizer PRIVATE /wd4291)
    endif()

    # shaderc
    add_executable(shaderc)
    add_executable(bgfx::shaderc ALIAS shaderc)

    file(GLOB SHADERC_SOURCES "tools/shaderc/*.cpp")
    target_sources(shaderc PRIVATE
        ${SHADERC_SOURCES}

        src/shader_spirv.cpp
        src/vertexdecl.cpp
    )

    target_include_directories(shaderc PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")

    target_link_libraries(shaderc PRIVATE
        glslang
        SPIRV

        spirv-cross-core
        spirv-cross-glsl
        spirv-cross-msl
        spirv-cross-reflect

        SPIRV-Tools
        SPIRV-Tools-opt

        Vulkan::Vulkan

        Bx::bx
        Bx::compat

        fcpp
        glsl-optimizer
    )
endif()

# installation logic
file(WRITE "${CMAKE_BINARY_DIR}/bgfx-config.cmake" "include(\"\${CMAKE_CURRENT_LIST_DIR}/bgfx-targets.cmake\")")

if (BGFX_INSTALL_TOOLING AND BGFX_WITH_TOOLING)
    install(TARGETS geometryc geometryv shaderc texturev EXPORT tool-targets)

    file(APPEND "${CMAKE_BINARY_DIR}/bgfx-config.cmake" "\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/tool-targets.cmake\"")
    install(EXPORT tool-targets NAMESPACE bgfx:: DESTINATION "${CMAKE_INSTALL_DATADIR}/bgfx/")
endif()

install(TARGETS bgfx EXPORT bgfx-targets)
if (NOT BGFX_DISABLE_HEADER_INSTALL)
    install(DIRECTORY include/bgfx TYPE INCLUDE)
    if (WIN32)
        install(FILES scripts/bgfx.natvis DESTINATION "${CMAKE_INSTALL_DATADIR}/bgfx/")
    endif()
endif()
install(EXPORT bgfx-targets NAMESPACE bgfx:: DESTINATION "${CMAKE_INSTALL_DATADIR}/bgfx/")
install(FILES "${CMAKE_BINARY_DIR}/bgfx-config.cmake" DESTINATION "${CMAKE_INSTALL_DATADIR}/bgfx/")

if (BGFX_WITH_EXAMPLES)

    macro(add_bgfx_example _EXAMPLE_NAME)

        add_executable(${_EXAMPLE_NAME})
        file(GLOB ${_EXAMPLE_NAME}_SOURCES examples/${_EXAMPLE_NAME}/*.cpp)
        target_sources(${_EXAMPLE_NAME} PRIVATE ${${_EXAMPLE_NAME}_SOURCES})
        target_compile_definitions(${_EXAMPLE_NAME} PRIVATE ENTRY_CONFIG_IMPLEMENT_MAIN=1)
        target_link_libraries(${_EXAMPLE_NAME} PRIVATE example-common)

    endmacro()

    file(GLOB _EXAMPLES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/examples/" "${CMAKE_CURRENT_SOURCE_DIR}/examples/*-*")
    list(REMOVE_ITEM _EXAMPLES 25-c99) # example build blacklist
    foreach(_EXAMPLE IN LISTS _EXAMPLES)
        add_bgfx_example(${_EXAMPLE})
    endforeach()

endif()
