vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO  "lsalzman/enet"
    REF 224f31101fc60939c02f6bbe8e8fc810a7db306b
    HEAD_REF master
    SHA512 6f820b5ce9df1cc94793dfced87d5039bdbe4e3fee44951d293158d37c79f2bd16d788a89f67f54ba4ee8570b46db28831f2becc4fe56659ea47f118e4f3f30c
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
