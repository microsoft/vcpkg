# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/nanobench
    REF v4.3.6
    SHA512 03e92a9fe903d273ee76c30bb6474c739858f0a65adebdcdd1e4b9ae294bd790a8e20161cb2d493fc1ea2987dbfa25a2a620cf7c3739d909595f81693f1f17d4
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/src/include/nanobench.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
