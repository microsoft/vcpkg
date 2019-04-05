include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KjellKod/g3log
    REF 9c5e7f3bcbe2c18984a7de7351da2451b23e45ed
    SHA512 3d989ec76e95a2a6863bd301bf00600b42d3fcf8ab2963385d79008bf3ec2621daa37638d17543736eaddf30d06979b24ae31ce0a37fe5eb842e14a15c1341b2
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" G3_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" G3_SHARED_RUNTIME)

set(VERSION 586)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DG3_SHARED_LIB=${G3_SHARED_LIB} # Options.cmake
        -DG3_SHARED_RUNTIME=${G3_SHARED_RUNTIME} # Options.cmake
        -DADD_FATAL_EXAMPLE=OFF
        -DADD_G3LOG_BENCH_PERFORMANCE=OFF
        -DADD_G3LOG_UNIT_TEST=OFF
        -DVERSION=${VERSION}
)

vcpkg_build_cmake()

set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

file(GLOB HEADER_FILES
    ${SOURCE_PATH}/src/g3log/*.hpp
    ${RELEASE_DIR}/include/g3log/generated_definitions.hpp
)

file(COPY ${HEADER_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/g3log
)

macro(install_if_exists source_dir target_dir filename)
    if (EXISTS ${source_dir}/${filename})
        file(INSTALL
            ${source_dir}/${filename}
            DESTINATION ${target_dir}
        )
    endif ()
endmacro()

install_if_exists(${DEBUG_DIR} ${CURRENT_PACKAGES_DIR}/debug/lib g3logger.lib)
install_if_exists(${RELEASE_DIR} ${CURRENT_PACKAGES_DIR}/lib g3logger.lib)

install_if_exists(${DEBUG_DIR} ${CURRENT_PACKAGES_DIR}/debug/bin g3logger.dll)
install_if_exists(${RELEASE_DIR} ${CURRENT_PACKAGES_DIR}/bin g3logger.dll)

install_if_exists(${DEBUG_DIR} ${CURRENT_PACKAGES_DIR}/debug/lib g3logger.a)
install_if_exists(${RELEASE_DIR} ${CURRENT_PACKAGES_DIR}/lib g3logger.a)

vcpkg_copy_pdbs()

configure_file(
    ${SOURCE_PATH}/cmake/g3loggerConfig.cmake
    ${CURRENT_PACKAGES_DIR}/share/g3logger/g3loggerConfig.cmake
    COPYONLY
)

# Install usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME g3logger)
