cmake_minimum_required(VERSION 3.20)
project(rlImGui LANGUAGES CXX)

add_library(rlImGui rlImGui.cpp)
add_library(unofficial::rlImGui::rlImGui ALIAS rlImGui)

target_include_directories(rlImGui PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

find_package(raylib CONFIG REQUIRED)
find_package(imgui CONFIG REQUIRED)

target_link_libraries(rlImGui PUBLIC raylib imgui)

install(TARGETS rlImGui EXPORT unofficial-rlImGuiConfig)
install(FILES rlImGui.h rlImGuiColors.h imgui_impl_raylib.h DESTINATION include)
install(EXPORT unofficial-rlImGuiConfig DESTINATION share/unofficial-rlImGui NAMESPACE unofficial::rlImGui::)
