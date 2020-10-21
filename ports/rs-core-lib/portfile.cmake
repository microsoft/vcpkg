include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 9eac3469ac13b2f1e9e4608a0710a76af68d1983 # accessed on 2020-09-14
    SHA512 ef3cb291efefff0ef13b683d70b99777cb403f5211a6f0e3099a91806cf3d7dd33d6e2e793ccbd836dcb145dc19cde99c4f4eb0bd49be3482d87d4e1a04ee2aa
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)