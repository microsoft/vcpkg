vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            cppslippi
    FILENAME        "CppSlippi-${VERSION}.zip"
    SHA512          5057758ed7da1f8d3bbdcd0eb783e93aa07d501a5333c48707f588bd3370551fce65a22074da9cbe4aa69fa32fa6c826a2aa039911cff7be5b8548842d135ece
    NO_REMOVE_ONE_LEVEL
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=False
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CppSlippi)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
