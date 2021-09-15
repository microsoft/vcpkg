vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/s2n-tls
    REF b5b313b9ccddf268b30c642798f1d2a58d49ecd6 # v1.0.17
    SHA512 59750c9a3c9330e2b26b84d45665b222d23475090736d8299f81352c839a09af10be0d49d34ced1dadae65ca255e819df45b648387e26b7dca31d74782fdb834
    PATCHES fix-cmake-target-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_cmake_install()

file(GLOB SHARED_CMAKE_FILES
     "${CURRENT_PACKAGES_DIR}/debug/lib/s2n"
     )
file(COPY "${SHARED_CMAKE_FILES}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
	"${CURRENT_PACKAGES_DIR}/lib/s2n"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE	"${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
