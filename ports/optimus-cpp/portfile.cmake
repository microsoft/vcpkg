vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kafeg/optimus-cpp
    REF 0.3.0
    SHA512 93abd13d4552a896f61e32dfebcc9037e7255f3fa86b230c03905df3148b9cc91cec772ec733e83fbcad574fd93fa4dadca9ec88b5836c5a4137d01e16580d6f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
