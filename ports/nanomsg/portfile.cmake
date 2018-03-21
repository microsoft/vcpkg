include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nanomsg
    REF 1.1.2
    SHA512 f95ce24b34c25d139cf3de46585f6354e0311a9d5e7135ad71df62b8bb5df26f81a58b9773c39c320df2d0e97cd2905a8576f9f00b0a4d33774f1b610271cee5
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
