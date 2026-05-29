vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chemeris/msinttypes
    REF f9e7c5758ed9e3b9f4b2394de1881c704dd79de0
    SHA512 943ccb1245e41ad554908fd7664725f2aac929222bd823b375fbd2e8a4c4ffc42c268543c43a817b65dca047c3253d04527378ec3902e5e7df7f6ba5a736d6f3
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/inttypes.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/msinttypes)
file(INSTALL ${SOURCE_PATH}/stdint.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/msinttypes)
file(INSTALL ${SOURCE_PATH}/stdint.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/msinttypes RENAME copyright)
