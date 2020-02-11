vcpkg_fail_port_install(ON_TARGET "Windows" "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-lambda-cpp
    REF 55276cef2efe18fe13457ebf85df53a81d68be59 # v0.2.6
    SHA512 a865b8c5715e884c0aeb0972d88919084a37b4837ade55d7f4373422c1ffa06a550f6bfe62b6f69b9eb3a352b9a1d4114c72d754bce2d6d3727bebd029fe6631
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

