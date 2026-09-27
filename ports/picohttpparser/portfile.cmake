vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h2o/picohttpparser
    REF f4d94b48b31e0abae029ebeafcfd9ca0680ede58
    SHA512 7d94d107572c0fcf138636fb0693e87b8302adf08265d6361763384d428f979d9c1f5a627ffa8ad2ee855ec29d3b5c39ee8fba63b5e757830c3bad266940cf54
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-picohttpparser)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/picohttpparser.h")
