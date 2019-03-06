include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yyzybb537/libgo
    REF v2.8
    SHA512 44784de4aec36ea321195c11c99a73de4f6f51285febdf6980e8aaced1fdfc0a34c6b1a8acc8c6b424e747310a1d7fb1604f722084c28ab91f8ebee15667d59b
    HEAD_REF master
    PATCHES
        cmake.patch
        boost-168.patch
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/XBased/xhook/archive/e18c450541892212ca4f11dc91fa269fabf9646f.tar.gz"
    FILENAME "xhook-e18c450541892212ca4f11dc91fa269fabf9646f.tar.gz"
    SHA512 1bcf320f50cff13d92013a9f0ab5c818c2b6b63e9c1ac18c5dd69189e448d7a848f1678389d8b2c08c65f907afb3909e743f6c593d9cfb21e2bb67d5c294a166
)

file(REMOVE_RECURSE ${SOURCE_PATH}/third_party)

vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH}/third_party)
file(RENAME ${SOURCE_PATH}/third_party/xhook-e18c450541892212ca4f11dc91fa269fabf9646f ${SOURCE_PATH}/third_party/xhook)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDISABLE_ADJUST_COMMAND_LINE_FLAGS=ON
        -DDISABLE_DYNAMIC_LIB=ON
        -DENABLE_BOOST_CONTEXT=ON
        -DFORCE_UNIX_TARGETS=ON
        -DDISABLE_SYSTEMWIDE=ON
)

vcpkg_install_cmake()

# remove duplicated include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/libgo/disable_hook)

file(GLOB REL_MAIN ${CURRENT_PACKAGES_DIR}/lib/libgo_main.lib ${CURRENT_PACKAGES_DIR}/lib/liblibgo_main.a)
if(REL_MAIN)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(COPY ${REL_MAIN} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(REMOVE ${REL_MAIN})
endif()

file(GLOB DBG_MAIN ${CURRENT_PACKAGES_DIR}/debug/lib/libgo_main.lib ${CURRENT_PACKAGES_DIR}/debug/lib/liblibgo_main.a)
if(DBG_MAIN)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(COPY ${DBG_MAIN} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(REMOVE ${DBG_MAIN})
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgo RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/libgo-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgo)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
