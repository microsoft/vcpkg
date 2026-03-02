vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-cxx-driver
    REF "r${VERSION}"
    SHA512 8a7c7d37120e97a8aafca5fea986b4e98e062466df7006ee311bb79bf0b16016a3d6070e18beffc236b145dfa86d5968aa66f5c4b8e6f0ba5683d960c695006f
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

file(WRITE "${SOURCE_PATH}/build/VERSION_CURRENT" "${VERSION}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_MONGO_CXX_DRIVER_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DBSONCXX_HEADER_INSTALL_DIR=include
        -DENABLE_TESTS=OFF
        -DENABLE_UNINSTALL=OFF
        -DMONGOCXX_HEADER_INSTALL_DIR=include
        -DNEED_DOWNLOAD_C_DRIVER=OFF
    MAYBE_UNUSED_VARIABLES
        BSONCXX_HEADER_INSTALL_DIR
        MONGOCXX_HEADER_INSTALL_DIR
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(PACKAGE_NAME "bsoncxx" CONFIG_PATH "lib/cmake/bsoncxx-${VERSION}" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME "mongocxx" CONFIG_PATH "lib/cmake/mongocxx-${VERSION}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

function(auto_clean dir)
    file(GLOB entries "${dir}/*")
    file(GLOB files LIST_DIRECTORIES false "${dir}/*")
    foreach(entry IN LISTS entries)
        if(entry IN_LIST files)
            continue()
        endif()
        file(GLOB_RECURSE children "${entry}/*")
        if(children)
            auto_clean("${entry}")
        else()
            file(REMOVE_RECURSE "${entry}")
        endif()
    endforeach()
endfunction()
auto_clean("${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
