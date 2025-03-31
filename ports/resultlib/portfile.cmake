# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO guillermocalvo/resultlib
    REF "${VERSION}"
    SHA512 a18522e84bb27c76993748909a9311eb479d0466ee11839b1d3d2ac7469c13534f332c17a6582e29a3de28bd34d0cc10045f2b7bb8e1894f5f345c367cd8e947
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/src/result.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/resultlib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
