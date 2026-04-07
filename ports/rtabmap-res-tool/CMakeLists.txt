cmake_minimum_required(VERSION 3.10)
project(rtabmap)
set(PROJECT_PREFIX rtabmap)

include(GenerateExportHeader)
include(GNUInstallDirs)

list(PREPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake_modules")

add_subdirectory(utilite)
