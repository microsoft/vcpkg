cmake_minimum_required(VERSION 3.16)
project(aui-test VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(aui CONFIG REQUIRED COMPONENTS core views curl json crypt updater)

aui_executable(${PROJECT_NAME})
aui_link(${PROJECT_NAME} PRIVATE aui::core aui::views aui::updater)
aui_compile_assets(${PROJECT_NAME})
aui_app(TARGET ${PROJECT_NAME} NAME "AUI CI Test" VENDOR "vcpkg"
        ICON "assets/img/icon.svg"
        ANDROID_PACKAGE "org.vcpkg.auitest")
