# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 1bc30cb6e4ce0fd2e288b2cd74d18f857801cbc7
    SHA512 c3d6b99273c2b2acdd366547119e78c25f788dabfae11f533aea8d31d03383b46516398370103b01e3b9bb0bb3921c981299cd3591107845630181b48e3b010e
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)