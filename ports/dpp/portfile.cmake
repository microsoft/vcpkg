vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brainboxdotcc/DPP
    REF "v${VERSION}"
    SHA512 4da74166ed68730ee60435fcac8ed79f206968a07c21228db14a7c1e7a39c922df7a8088276528b620d285d34529e2ce61f7bb03eccef8fea6231e81537d874d
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/dpp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
