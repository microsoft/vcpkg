vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmannett85/arg_router
    REF v1.1.1
    HEAD_REF main
    SHA512 2951a54b4fb13abd10d4de3711d4d92f180e582c21e9a0d3599cb327e799727e826ea87aecd0fd7a6203585eac5a934afe25f98488ef6b36c12be97450ab8020
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DINSTALLATION_ONLY=ON
)

vcpkg_cmake_install()
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(
    COPY "${CURRENT_PACKAGES_DIR}/include/arg_router/arg_router-config.cmake"
         "${CURRENT_PACKAGES_DIR}/include/arg_router/arg_router-config-version.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/arg_router"
)
file(
    COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

