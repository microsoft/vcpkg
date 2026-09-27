cmake_minimum_required(VERSION 3.15)

project(vcpkg-ci-qt5-quickcontrols2)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 QmlImportScanner REQUIRED)

add_executable(vcpkg-ci-qt5-quickcontrols2 main.cpp resources.qrc)

target_compile_definitions(vcpkg-ci-qt5-quickcontrols2 PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(vcpkg-ci-qt5-quickcontrols2 PRIVATE Qt5::Core Qt5::Quick Qt5::QuickControls2)

qt5_import_qml_plugins(vcpkg-ci-qt5-quickcontrols2)
