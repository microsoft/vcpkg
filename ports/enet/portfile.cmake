include(vcpkg_common_functions)
vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO  "lsalzman/enet"
    REF 224f31101fc60939c02f6bbe8e8fc810a7db306b
    HEAD_REF master
    SHA512 9205a3c7fdcf09ad2c43280b48f20ff30102fb9ddbbbedc82a638cfb190c8169e46015921a2729f4da2356b934462ae46f6e0b4d769e4451f8433cb07d9b0755
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
