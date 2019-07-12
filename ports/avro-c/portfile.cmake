include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/avro
  REF 3c76495e9524ef322726d03d7ee406be89e8fde0
  SHA512 05cd16d4281c11e891132bae4853064ded0c9b630b41ef90e2940f16fde97640de4b0393c6f257c6f52b91b38595a849051e2f2bde29271198c1a44378e52400
  HEAD_REF master
  PATCHES
        avro.patch
        avro-pr-217.patch
        fix-build-error.patch # Since jansson updated, use jansson::jansson instead of the macro ${JANSSON_LIBRARIES}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Snappy=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/lang/c/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/avro-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/avro-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/avro-c/copyright)
