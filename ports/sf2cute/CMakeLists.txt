cmake_minimum_required(VERSION 3.8.2)

project(sf2cute
    LANGUAGES C CXX
    VERSION 0.2.0)

#============================================================================
# sf2cute library
#============================================================================
add_library(sf2cute "")

target_sources(sf2cute
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/file.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/file_writer.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/generator_item.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/instrument.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/instrument_zone.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/modulator.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/modulator_key.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/modulator_item.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/preset.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/preset_zone.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_ibag_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_igen_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_imod_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_inst_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_pbag_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_pgen_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_phdr_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_pmod_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_shdr_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/riff_smpl_chunk.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/sample.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute/zone.cpp
)

target_include_directories(sf2cute
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/src/sf2cute
)

set_target_properties(sf2cute PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

target_compile_features(sf2cute PUBLIC cxx_std_14)

add_library(sf2cute::sf2cute ALIAS sf2cute)

#============================================================================
# Install and Export sf2cute
#============================================================================

include(GNUInstallDirs)

# install library files needed for linking
install(
    TARGETS sf2cute
    EXPORT sf2cute-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# install the public header files
install(
    DIRECTORY ${CMAKE_SOURCE_DIR}/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# installs the *cmake files in share directory
install(
    EXPORT sf2cute-targets
    FILE sf2cute-targets.cmake
    NAMESPACE sf2cute::
    DESTINATION share/sf2cute
)

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
    ${CMAKE_BINARY_DIR}/cmake/sf2cute-config-version.cmake
    VERSION ${SF2CUTE_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/cmake/sf2cute-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/sf2cute-config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/sf2cute
)

install(
    FILES
        ${CMAKE_BINARY_DIR}/cmake/sf2cute-config.cmake
        ${CMAKE_BINARY_DIR}/cmake/sf2cute-config-version.cmake
    DESTINATION share/sf2cute
)
