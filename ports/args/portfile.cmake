include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF b8fc68ac37103a3b35d013ff10d0b623a3d6a75d
    SHA512 8f325b5224aa572dd9040a075207552a1f80fb6ddebf459774daedf1a1ad440fe0629fbf9616f9899906529aaa825be2531f33655d84e997d211782546e2de87
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/args.hxx DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/args)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/args/LICENSE ${CURRENT_PACKAGES_DIR}/share/args/copyright)

