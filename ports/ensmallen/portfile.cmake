vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF ba0897d57f52db9578e5e44426eb3220d5bd917f # v2.11.2
    SHA512 715c87b407487c1b5f1b2e95c23151c80d84bda8e5bd879f71e41871bc9a10bb157acf67fa2814b180da4c426a842bf84f29ce0d3bd3a2df4bfab382f5bb04d3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DBUILD_TESTS=OFF
)
vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


