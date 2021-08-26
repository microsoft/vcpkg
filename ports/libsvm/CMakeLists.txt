cmake_minimum_required(VERSION 3.14)

project(libsvm LANGUAGES C CXX)

include(GNUInstallDirs)

option(SVM_BUILD_TOOLS "Build SVM tools" OFF)

set(libsvm_sources svm.cpp)
if (WIN32)
    list(APPEND libsvm_sources svm.def)
endif ()

add_library(libsvm ${libsvm_sources})

target_compile_definitions(
    libsvm
    PRIVATE
        $<$<C_COMPILER_ID:MSVC>:
            _CRT_SECURE_NO_WARNINGS
            strdup=_strdup
        >
)

target_include_directories(
    libsvm
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(libsvm PROPERTIES PUBLIC_HEADER svm.h)

install(TARGETS libsvm EXPORT unofficial-libsvm-config)

install(
    EXPORT unofficial-libsvm-config
    NAMESPACE unofficial::libsvm::
    DESTINATION share/unofficial-libsvm
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)

if (SVM_BUILD_TOOLS)
    add_executable(svm-predict svm-predict.c)
    target_link_libraries(svm-predict PRIVATE libsvm)

    add_executable(svm-scale svm-scale.c)
    target_link_libraries(svm-scale PRIVATE libsvm)

    add_executable(svm-train svm-train.c)
    target_link_libraries(svm-train PRIVATE libsvm)

    install(TARGETS svm-predict svm-scale svm-train)

    if (WIN32)
        add_executable(svm-toy svm-toy/windows/svm-toy.cpp)
        target_link_libraries(svm-toy PRIVATE libsvm)
        set_target_properties(svm-toy PROPERTIES WIN32_EXECUTABLE ON)

        install(TARGETS svm-toy)
    endif ()
endif ()
