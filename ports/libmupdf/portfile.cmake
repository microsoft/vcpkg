vcpkg_fail_port_install(ON_TARGET "osx")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF 96751b25462f83d6e16a9afaf8980b0c3f979c8b # 1.17.0
    SHA512 ee8603a606895c7362fc44905f627f2a05e3c9d8a682b27051b5c67dac971719e315a08da3cd51107024bcc67d7d43cafcb9a6ad8b534c89a55982001f400537
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/include/mupdf DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
