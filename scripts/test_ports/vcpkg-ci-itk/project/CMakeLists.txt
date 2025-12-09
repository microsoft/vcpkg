cmake_minimum_required(VERSION 3.7)
project(itk-test)

find_package(ITK CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE
    $<TARGET_NAME:ITKFFT>
)
