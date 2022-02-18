cmake_minimum_required(VERSION 3.4)
project(libopusenc C)

if(MSVC)
 set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4267 /wd4244 /wd4996 /wd4101 /wd4018")
endif()

find_path(OPUS_INCLUDE_DIR opus.h PATH_SUFFIXES opus)
find_library(OPUS_LIBRARY opus)

add_library(opusenc
    src/ogg_packer.c
    src/opus_header.c
    src/opusenc.c
    src/picture.c
    src/resample.c
    src/unicode_support.c)

get_filename_component(FOLDER ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE "libopusenc-" "" VERSION ${FOLDER})

target_compile_definitions(opusenc PRIVATE
    RANDOM_PREFIX=libopusenc
    OUTSIDE_SPEEX
    FLOATING_POINT
    PACKAGE_VERSION="${VERSION}"
    PACKAGE_NAME="libopusenc"
    OPE_BUILD)
set_target_properties(opusenc PROPERTIES DEFINE_SYMBOL DLL_EXPORT)
target_include_directories(opusenc PRIVATE include ${OPUS_INCLUDE_DIR})
target_link_libraries(opusenc PRIVATE ${OPUS_LIBRARY})

install(TARGETS opusenc
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

if(NOT OPUSENC_SKIP_HEADERS)
    install(FILES include/opusenc.h
        DESTINATION include/opus)
endif()
