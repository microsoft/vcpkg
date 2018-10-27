include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nanomsg
    REF 1.1.4
    SHA512 a1f002f988f2d98eff03387b496fe15a099fef4eb9ccd1c46ade63fbbe5a4ad4cf9fa0fd1e612e1a6f2747bc2af63b7044ec1e920e1c9a0d8c8bc2191ad7046a
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" NN_STATIC_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
        -DNN_STATIC_LIB=${NN_STATIC_LIB}
        -DNN_TESTS=OFF
        -DNN_TOOLS=OFF
        -DNN_ENABLE_DOC=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/nanomsg")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ ${CURRENT_PACKAGES_DIR}/include/nanomsg/nn.h _contents)
    string(REPLACE "defined(NN_STATIC_LIB)" "1" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/nanomsg/nn.h "${_contents}")
endif()

file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/nanomsg RENAME copyright)

vcpkg_copy_pdbs()
