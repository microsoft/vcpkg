cmake_minimum_required(VERSION 3.24)

project(vcpkg-ci-qtwebengine LANGUAGES C CXX)

add_executable(main main.cpp)

if("pdf" IN_LIST FEATURES)
    find_package(Qt6 REQUIRED COMPONENTS Pdf)
    target_link_libraries(main PRIVATE Qt6::Pdf)
    target_compile_definitions(main PRIVATE REQUIRE_PDF)
endif()

if("webengine" IN_LIST FEATURES)
    find_package(Qt6 REQUIRED COMPONENTS WebEngineCore)
    target_link_libraries(main PRIVATE Qt6::WebEngineCore)
    target_compile_definitions(main PRIVATE REQUIRE_WEBENGINE)
endif()
