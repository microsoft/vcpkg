cmake_minimum_required(VERSION 3.29)
project(juce-test VERSION 1 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 11)

option(WITH_CURL "Link curl")

find_package(JUCE CONFIG REQUIRED)

juce_add_console_app(core
    PRODUCT_NAME "vcpkg-ci-juce"
    NEEDS_CURL   "${WITH_CURL}"
)
target_sources(core PRIVATE main.cpp)
target_link_libraries(core PRIVATE juce::juce_core)

juce_add_console_app(everything
    PRODUCT_NAME "vcpkg-ci-juce"
    NEEDS_CURL   "${WITH_CURL}"
)
target_sources(everything PRIVATE main.cpp)
file(GLOB all_modules RELATIVE "${JUCE_MODULES_DIR}" "${JUCE_MODULES_DIR}/*")
list(TRANSFORM all_modules PREPEND juce::)
target_link_libraries(everything PRIVATE ${all_modules})
target_compile_definitions(everything PRIVATE JUCE_WEB_BROWSER=0)
