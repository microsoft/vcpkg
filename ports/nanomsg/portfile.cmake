include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nanomsg
    REF 1.1.5
    SHA512 773b8e169a7accac21414c63972423a249164f5b843c6c65c1b03a2eb90d21da788a98debdeb396dab795e52d30605696bc2cf65e5e05687bf115438d5b22717
    HEAD_REF master
    PATCHES
        fix-install-destination.patch
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ ${CURRENT_PACKAGES_DIR}/include/nanomsg/nn.h _contents)
    string(REPLACE "defined(NN_STATIC_LIB)" "1" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/nanomsg/nn.h "${_contents}")
endif()

file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/nanomsg RENAME copyright)

vcpkg_copy_pdbs()
