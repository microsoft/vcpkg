include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alanxz/rabbitmq-c
  REF ffe918a5fcef72038a88054dca3c56762b1953d4 # v0.10.0
  SHA512 05756176feffc3ccff9bf4f8416191c382c9e5b51d7dd72664cea0407c847d50cb4048b8669415d879396c0c7e8c1c38c65a66a98701e55de09afed893abc5a0
  HEAD_REF master
  PATCHES
	fix-uwpwarning.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_TOOLS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(INSTALL ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/librabbitmq RENAME copyright)
