include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alanxz/rabbitmq-c
  REF 58ade1a2a3b486d2c211ea24899b5e99231c7af4
  SHA512 e32d2e780af1ab295d7f9a82d5f3e1b892c04f23b39e221db40c9b6ce6f132cdab2ae27626fa8e97971bd4dcad19cb714b38c6e2c56c56f97e1edfc1d8e11ff9
  HEAD_REF master
  PATCHES
	fix-uwpwarning.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_TOOLS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(INSTALL ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/librabbitmq RENAME copyright)
