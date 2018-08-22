include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yyzybb537/libgo
    REF v3.0-beta
    SHA512 b60803a8dcaac942fce23d101e8563ec4d850c9d477dc3d116db7f104404acc89a589ac7a0577c2425f2f65a79da211343fa5491cb3ee11c2b34af6883b4e4ba
    HEAD_REF master
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/XBased/xhook/archive/e18c450541892212ca4f11dc91fa269fabf9646f.tar.gz"
    FILENAME "xhook-e18c450541892212ca4f11dc91fa269fabf9646f.tar.gz"
    SHA512 1bcf320f50cff13d92013a9f0ab5c818c2b6b63e9c1ac18c5dd69189e448d7a848f1678389d8b2c08c65f907afb3909e743f6c593d9cfb21e2bb67d5c294a166
)

#vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH}/third_party/xhook)
#file(REMOVE_RECURSE ${SOURCE_PATH}/third_party/xhook)
#file(RENAME ${SOURCE_PATH}/third_party/xhook-e18c450541892212ca4f11dc91fa269fabf9646f ${SOURCE_PATH}/third_party/xhook)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDISABLE_ADJUST_COMMAND_LINE_FLAGS=ON
        -DDISABLE_SYSTEMWIDE=ON
)

vcpkg_install_cmake()

# remove duplicated include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/libgo/netio/unix/static_hook)

file(GLOB DBG_STATICHOOK ${CURRENT_PACKAGES_DIR}/debug/lib/libgo_static_hook.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libstatic_hook.a)
if(DBG_STATICHOOK)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(COPY ${DBG_STATICHOOK} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(REMOVE ${DBG_STATICHOOK})
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgo RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/libgo-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgo)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
