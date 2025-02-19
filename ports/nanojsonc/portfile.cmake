vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-source-patterns/nanojsonc
        REF "${VERSION}"
        SHA512 8fe36b742b994598d6f5ae30433245f63da5378ff6866f593cf53916e2b2fdc5d85ddc88d20908fd1166c3568f62e2a8dd837270855cb603dad88246a726be51
        HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -DBUILD_TESTS=OFF)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup() # removes /debug/share
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") # removes debug/include

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") # Install License
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # Install Usage
