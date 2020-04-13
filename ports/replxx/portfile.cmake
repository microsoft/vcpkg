vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO AmokHuginnsson/replxx
        REF 45696c250ce39ab21dedeea962b94d7827007a8c
        SHA512 7beec508fa3049fe5a736a487728506d646d26d7194ef7453fc07bceade1982430808fab0a10ca9b1c43a8b87bf3a973f5cfe4aa22ed06927647c9a7244167fd
        HEAD_REF master
)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        DISABLE_PARALLEL_CONFIGURE
        PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/replxxConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
