cmake_minimum_required(VERSION 3.9)
project(liblinear)

add_definitions(-D_CRT_SECURE_NO_DEPRECATE)

add_library(blas OBJECT
    blas/daxpy.c
    blas/ddot.c
    blas/dnrm2.c
    blas/dscal.c
)

add_library(liblinear
    linear.cpp
    newton.cpp
    $<TARGET_OBJECTS:blas>
)
target_include_directories(liblinear PRIVATE .)
if(BUILD_SHARED_LIBS)
    target_link_libraries(liblinear PRIVATE "-DEF:${CMAKE_CURRENT_SOURCE_DIR}/linear.def")
endif()

add_executable(train train.c $<TARGET_OBJECTS:blas>)
target_link_libraries(train liblinear)

add_executable(predict predict.c $<TARGET_OBJECTS:blas>)
target_link_libraries(predict liblinear)

install(
    TARGETS liblinear
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
    install(
        TARGETS train predict
        RUNTIME DESTINATION tools/liblinear
    )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        FILES linear.h newton.h
        DESTINATION include/liblinear)
endif()