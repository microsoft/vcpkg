vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-cxx-driver
    REF "r${VERSION}"
    SHA512 7b6564cb5087b03886f3c99aa5da9e87a898b1bd1098393a7668e39d673d6203a39f7fa95e5bef995f5e53c18654ef1806823cf643a994a8c19a1df75b9eb306
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
