vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nanomsg
    REF 1.1.5
    SHA512 773b8e169a7accac21414c63972423a249164f5b843c6c65c1b03a2eb90d21da788a98debdeb396dab795e52d30605696bc2cf65e5e05687bf115438d5b22717
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" NN_STATIC_LIB)

if("tool" IN_LIST FEATURES)
    set(NN_ENABLE_NANOCAT ON)
else()
    set(NN_ENABLE_NANOCAT OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
        -DNN_STATIC_LIB=${NN_STATIC_LIB}
        -DNN_TESTS=OFF
        -DNN_TOOLS=OFF
        -DNN_ENABLE_DOC=OFF
        -DNN_ENABLE_NANOCAT=${NN_ENABLE_NANOCAT}
)

vcpkg_install_cmake()

file(STRINGS ${SOURCE_PATH}/.version NN_PACKAGE_VERSION)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nanomsg-${NN_PACKAGE_VERSION})

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/nanomsg-config.cmake
    "lib/cmake/nanomsg-${NN_PACKAGE_VERSION}"
    "share/nanomsg"
)

if(NN_ENABLE_NANOCAT)
    vcpkg_copy_tools(TOOL_NAMES nanocat AUTO_CLEAN)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/nanomsg/nn.h
        "defined(NN_STATIC_LIB)"
        "1 // defined(NN_STATIC_LIB)"
    )

    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/nanomsg-config.cmake
        "set_and_check(nanomsg_BINDIR \${PACKAGE_PREFIX_DIR}/bin)"
        ""
    )
endif()

configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
