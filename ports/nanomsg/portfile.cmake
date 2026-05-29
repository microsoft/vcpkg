vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nanomsg
    REF "${VERSION}"
    SHA512 76162319588d7ba7668f373147629ec2a178d247ac0518b24d129ea579f9c19cc45c544744ed9fe89ab7e74750da7c644d9565731d22f1199bf0ccfc5c734e56
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" NN_STATIC_LIB)

if("tool" IN_LIST FEATURES)
    set(NN_ENABLE_NANOCAT ON)
else()
    set(NN_ENABLE_NANOCAT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
        -DNN_STATIC_LIB=${NN_STATIC_LIB}
        -DNN_TESTS=OFF
        -DNN_TOOLS=OFF
        -DNN_ENABLE_DOC=OFF
        -DNN_ENABLE_NANOCAT=${NN_ENABLE_NANOCAT}
)

vcpkg_cmake_install()

file(STRINGS ${SOURCE_PATH}/.version NN_PACKAGE_VERSION)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/nanomsg-${NN_PACKAGE_VERSION})

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
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/nanomsg-config.cmake
        "set_and_check(nanomsg_BINDIR \${VCPKG_IMPORT_PREFIX}/bin)"
        ""
        IGNORE_UNCHANGED
    )
endif()

configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
