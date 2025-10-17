cmake_minimum_required(VERSION 3.16)
project(libigl-test C CXX)

set(CMAKE_CXX_STANDARD 11)

add_definitions("-DTUTORIAL_SHARED_PATH=\"${SOURCE_PATH}/placeholder\"")

find_package(libigl CONFIG REQUIRED)

add_executable(101_FileIO "${SOURCE_PATH}/tutorial/101_FileIO/main.cpp")
target_link_libraries(101_FileIO PRIVATE igl::igl_core)

if("glfw" IN_LIST FEATURES)
    add_executable(102_DrawMesh "${SOURCE_PATH}/tutorial/102_DrawMesh/main.cpp")
    target_link_libraries(102_DrawMesh PRIVATE igl::igl_glfw)

    add_executable(111_MatCap "${SOURCE_PATH}/tutorial/111_MatCap/main.cpp" "${CMAKE_CURRENT_LIST_DIR}/stb_image_implementation.c")
    target_link_libraries(111_MatCap PRIVATE igl::igl_glfw igl::igl_stb)
endif()

if("imgui" IN_LIST FEATURES)
    add_executable(109_ImGuizmo "${SOURCE_PATH}/tutorial/109_ImGuizmo/main.cpp")
    target_link_libraries(109_ImGuizmo PRIVATE igl::igl_imgui)

    add_executable(113_Shadows "${SOURCE_PATH}/tutorial/113_Shadows/main.cpp" "${CMAKE_CURRENT_LIST_DIR}/stb_image_implementation.c")
    target_link_libraries(113_Shadows PRIVATE igl::igl_imgui igl::igl_stb)
endif()
