include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/thrift
    REF 286eee16b147a302ddc7b10740c5e5401ebbec17
    SHA512 83aff3a51281ec43228e66b33d15b344710030ee59c1373c6cf33efae9d26db1896ae3518a23b641a7897724d496c38b5217bfc7c41ff538648ec4c571b924f5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    OPTIONS
        -DWITH_STDTHREADS=ON
        -DBUILD_TESTING=off
        -DBUILD_JAVA=off
        -DBUILD_C_GLIB=off
        -DBUILD_PYTHON=off
        -DBUILD_CPP=on
        -DBUILD_HASKELL=off
        -DBUILD_TUTORIALS=off
        -DFLEX_EXECUTABLE=${FLEX}
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=TRUE
        -DBISON_EXECUTABLE=${BISON}
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/thrift RENAME copyright)

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/thrift)

file(GLOB COMPILER "${CURRENT_PACKAGES_DIR}/bin/thrift*")
if(COMPILER)
    file(COPY ${COMPILER} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/thrift)
    file(REMOVE ${COMPILER})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/thrift)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
vcpkg_copy_pdbs()
