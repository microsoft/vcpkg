vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow-nanoarrow
    REF "apache-arrow-nanoarrow-${VERSION}"
    SHA512 6d2bb68e4f35b42f543cf33aa5acf585690da5ffafe9d144da03473dc1e0a0834944abea719ba9b88296832bd3cc2e09a97f69552dec61a8d4a95fb78f0df405
    HEAD_REF main
)


file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND FEATURE_OPTIONS "-DARROW_USE_NATIVE_INT128=OFF")
endif()

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" NANOARROW_ARROW_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOARROW_ARROW_STATIC=${NANOARROW_ARROW_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME nanoarrow
    CONFIG_PATH lib/cmake/nanoarrow
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/nanoarrow.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/nanoarrow.dll" "${CURRENT_PACKAGES_DIR}/bin/nanoarrow.dll")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/nanoarrow.dll")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/nanoarrow.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/nanoarrow.dll")
endif()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake" "${CURRENT_PACKAGES_DIR}/lib/cmake")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
