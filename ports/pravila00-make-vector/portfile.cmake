vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pravila00/make-vector
    REF 1518ac00adec9b13a645aee45ed1a36eb6ec1e98
    SHA512 2be4af258ceeb71e990ecc5c1c2c269456f6621b7b6b8183ba4e29f5479c4c7a618bd0c737a8d66aa00052a710930ec2f2ee5bc925f7a627427ac90918b6d4fa
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/make_vector.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/make-vector")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
