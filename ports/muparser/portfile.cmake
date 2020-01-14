include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO beltoforion/muparser
  REF v2.2.6.1
  SHA512 01bfc8cc48158c8413ae5e1da2ddbac1c9f0b9075470b1ab75853587d641dd195ebea268e1060a340098fd8015bc5f77d8e9cde5f81cffeade2f157c5f295496
  HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DENABLE_SAMPLES=OFF
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/muparser RENAME copyright)
