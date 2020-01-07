include(vcpkg_common_functions)
vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO  "lsalzman/enet"
    REF f7c46f03fd8d883ac2811948aa71c7623069d070
    HEAD_REF master
    SHA512 2d5593ea56473b38479921fd0849318bf3ecb233f92fa487ba395a0bb7e6a3997109287867a67c66721f761a30cceab4ba4709080a93ed977b7650b10cab1936
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
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
