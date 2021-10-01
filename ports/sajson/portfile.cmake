# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chadaustin/sajson
    REF 2dcfd350586375f9910f74821d4f07d67ae455ba
    SHA512 6029a640f8bd6c7cefc507819a18a708f6d7e9ce84fdd2998506cea26d597b999d2776a7307908f5df02994bc53c3c9bdf6a73344ab70ee6a5c775b54351e7d2
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/unofficial-sajson TARGET_PATH share/unofficial-sajson)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/sajson/copyright COPYONLY)
