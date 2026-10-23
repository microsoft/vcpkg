cmake_minimum_required(VERSION 3.16)

project(piex LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# See https://github.com/google/piex/blob/master/piex.gyp
if(MSVC)
    add_compile_options(/W3 /wd4005 /wd4996 /wd4018)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
else()
    add_compile_options(-Wsign-compare -Wsign-conversion -Wunused-parameter)
endif()

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

add_library(binary_parse
    src/binary_parse/cached_paged_byte_array.cc
    src/binary_parse/cached_paged_byte_array.h
    src/binary_parse/range_checked_byte_ptr.cc
    src/binary_parse/range_checked_byte_ptr.h
)
target_compile_features(binary_parse PUBLIC cxx_std_20)

add_library(image_type_recognition
    src/image_type_recognition/image_type_recognition_lite.cc
)
target_compile_features(image_type_recognition PUBLIC cxx_std_20)
target_link_libraries(image_type_recognition PRIVATE
    binary_parse
)

add_library(tiff_directory
    src/tiff_directory/tiff_directory.cc
    src/tiff_directory/tiff_directory.h
)
target_compile_features(tiff_directory PUBLIC cxx_std_20)
target_link_libraries(tiff_directory PRIVATE
    binary_parse
)

add_library(piex
    src/piex.cc
    src/piex.h
    src/piex_cr3.cc
    src/piex_cr3.h
    src/piex_types.h
    src/tiff_parser.cc
    src/tiff_parser.h
)
target_compile_features(piex PUBLIC cxx_std_20)
target_link_libraries(piex PUBLIC
    tiff_directory
    image_type_recognition
    binary_parse
)

include(GNUInstallDirs)
install(
    TARGETS piex tiff_directory image_type_recognition binary_parse
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        FILES
            src/piex.h
            src/piex_types.h 
            src/piex_cr3.h
            src/tiff_parser.h
        DESTINATION include/src
    )

    install(
        FILES
            src/binary_parse/cached_paged_byte_array.h
            src/binary_parse/range_checked_byte_ptr.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/piex/binary_parse
    )

    install(
        FILES
            src/image_type_recognition/image_type_recognition_lite.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/piex/image_type_recognition
    )

    install(
        FILES
            src/tiff_directory/tiff_directory.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/piex/tiff_directory
    )
endif()
