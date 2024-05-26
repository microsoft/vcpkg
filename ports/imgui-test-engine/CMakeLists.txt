cmake_minimum_required(VERSION 3.16)
project(imgui-test-engine CXX)

set(CMAKE_DEBUG_POSTFIX d)

if(APPLE)
    set(CMAKE_CXX_STANDARD 11)
    enable_language(OBJCXX)
endif()

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)
target_compile_definitions(${PROJECT_NAME}
    PUBLIC
        IMGUI_TEST_ENGINE_ENABLE_COROUTINE_STDTHREAD_IMPL=1
    PRIVATE
        IMGUI_TEST_ENGINE_ENABLE_CAPTURE=1
)

find_package(Stb REQUIRED)

target_include_directories(
    ${PROJECT_NAME}
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine>"
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${Stb_INCLUDE_DIR}
)

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_capture_tool.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_context.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_coroutine.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_engine.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_exporters.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_perftool.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_ui.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_utils.cpp
)

if(IMGUI_TEST_ENGINE_IMPLOT)
    find_package(implot CONFIG REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE implot::implot)
    target_compile_definitions(${PROJECT_NAME} PRIVATE IMGUI_TEST_ENGINE_ENABLE_IMPLOT=1)
endif()

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_target
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

if(NOT IMGUI_TEST_ENGINE_SKIP_HEADERS)
    install(
        FILES
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_capture_tool.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_context.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_coroutine.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_engine.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_exporters.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_imconfig.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_internal.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_perftool.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_ui.h
            ${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine/imgui_te_utils.h
        DESTINATION
            include
    )
endif()

include(CMakePackageConfigHelpers)
configure_package_config_file(imgui-test-engine-config.cmake.in imgui-test-engine-config.cmake INSTALL_DESTINATION share/imgui-test-engine)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/imgui-test-engine-config.cmake DESTINATION share/imgui-test-engine)

install(
    EXPORT ${PROJECT_NAME}_target
    NAMESPACE ${PROJECT_NAME}::
    FILE ${PROJECT_NAME}-targets.cmake
    DESTINATION share/${PROJECT_NAME}
)
