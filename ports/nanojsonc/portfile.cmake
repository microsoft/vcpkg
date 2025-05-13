vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-source-patterns/nanojsonc
        REF "${VERSION}"
        SHA512 a83f38c67222d227faf352495b174a16ff6d5a0a45e9d6eda499ca6e8978d2dba184f820c7b726d80468a11fee02460cbd8b189d69a46716bd01c46e7b0607fd
        HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -DBUILD_TESTS=OFF)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup() # removes /debug/share
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") # removes debug/include

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") # Install License
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # Install Usage
