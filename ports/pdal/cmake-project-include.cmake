include(CheckIncludeFileCXX)

check_include_file_cxx("filesystem" HAVE_CXX17_FILESYSTEM)
if(NOT HAVE_CXX17_FILESYSTEM)
    message(FATAL_ERROR "Unable to find <filesystem> header. PDAL requires full C++17 compiler support.")
endif()

set_source_files_properties("${PROJECT_SOURCE_DIR}/io/OGRWriter.cpp" PROPERTIES COMPILE_DEFINITIONS NOMINMAX)
