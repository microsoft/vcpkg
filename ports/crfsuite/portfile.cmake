vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chokkan/crfsuite
    REF 5d1bd3b803bb26582ed5cc274d6b5af6cc7f9cae
    SHA512 e7f329f96fb0dc0e347b3e7a3e26b23ceb45e6fae7b59ace05633a24d58a31665826ebc5280e5a864f50598772791e4b5b3e7da7f46994655cbe03806f823f73
    HEAD_REF master
)

list(REMOVE_ITEM SOURCE_FILE "${SOURCE_PATH}/win32/liblbfgs/lbfgs.lib")
list(REMOVE_ITEM SOURCE_FILE "${SOURCE_PATH}/win32/liblbfgs/lbfgs_debug.lib")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFIX_NINJA
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
