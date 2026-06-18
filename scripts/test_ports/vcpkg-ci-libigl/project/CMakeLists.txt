cmake_minimum_required(VERSION 3.16)
project(libigl-test C CXX)

set(CMAKE_CXX_STANDARD 11)

add_definitions("-DTUTORIAL_SHARED_PATH=\"${SOURCE_PATH}/placeholder\"")

find_package(libigl CONFIG REQUIRED)

# Other than in the upstream build ("${SOURCE_PATH}/tutorial/CMakeLists.txt"),
# the imported targets use a different prefix, e.g.
# igl::glfw            -> igl::igl_glfw
# igl_copyleft::cgal   -> igl_copyleft::igl_copyleft_cgal

add_executable(101_FileIO "${SOURCE_PATH}/tutorial/101_FileIO/main.cpp")
target_link_libraries(101_FileIO PRIVATE igl::igl_core)

if("cgal" IN_LIST FEATURES)
    add_executable(609_Boolean "${SOURCE_PATH}/tutorial/609_Boolean/main.cpp")
    target_link_libraries(609_Boolean PRIVATE igl::igl_glfw igl_copyleft::igl_copyleft_cgal)
endif()

if("embree" IN_LIST FEATURES)
    add_executable(706_FacetOrientation "${SOURCE_PATH}/tutorial/706_FacetOrientation/main.cpp")
    target_link_libraries(706_FacetOrientation PRIVATE igl::igl_glfw igl::igl_embree)
endif()

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

if("xml" IN_LIST FEATURES)
    add_executable(601_Serialization "${SOURCE_PATH}/tutorial/601_Serialization/main.cpp")
    target_link_libraries(601_Serialization PRIVATE igl::igl_xml)
endif()
