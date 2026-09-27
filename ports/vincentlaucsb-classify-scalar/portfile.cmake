set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/classify_scalar
    REF ${VERSION}
    SHA512 26ff1a3e80ccf539f5da270ef97ce5c85044800483b8b9b4079ee84abf70865fc0c7cd0137061077536f641d099b08d9a022450885d47d6759872ae6b2db5026
    HEAD_REF main
)

file(INSTALL ${SOURCE_PATH}/include/classify_scalar.hpp  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
