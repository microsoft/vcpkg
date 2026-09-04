cmake_minimum_required(VERSION 3.15)

project(vcpkg-ci-qtquickcontrols2)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core Qml Quick QuickControls2 REQUIRED)

add_executable(vcpkg-ci-qtquickcontrols2 main.cpp resources.qrc)

target_compile_definitions(vcpkg-ci-qtquickcontrols2 PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(vcpkg-ci-qtquickcontrols2 PRIVATE Qt6::Core Qt6::Qml Qt6::Quick Qt6::QuickControls2)

qt_import_qml_plugins(vcpkg-ci-qtquickcontrols2)
