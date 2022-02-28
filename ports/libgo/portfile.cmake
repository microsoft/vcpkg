vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yyzybb537/libgo
    REF 5d4f36508e8eb2d5aa17cf37cd951dc91da23096 #v3.1
    SHA512 0f281f58116148ba1dd3904febbc391d47190f8e148b70bed7c4b7e6cb3efa5e41e2b7be4832ceeb805996e085f4c2d89fd0cf3b0651e037b32758d6a441411b
    HEAD_REF master
    PATCHES
        cmake.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH XHOOK_SOURCE_PATH
    REPO XBased/xhook
    REF e18c450541892212ca4f11dc91fa269fabf9646f
    SHA512 1bcf320f50cff13d92013a9f0ab5c818c2b6b63e9c1ac18c5dd69189e448d7a848f1678389d8b2c08c65f907afb3909e743f6c593d9cfb21e2bb67d5c294a166
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/third_party")
file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party")
file(RENAME "${XHOOK_SOURCE_PATH}" "${SOURCE_PATH}/third_party/xhook")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/libgo/netio/disable_hook")

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/libgo/netio/unix/static_hook")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/libgo/netio/windows")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/libgo/netio/unix")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
