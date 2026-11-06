set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Auburn/FastNoiseLite
    REF "v${VERSION}"
    SHA512 9eaf53d99593d7c5b60e2be1ed1e4ac274bb523bd94847b5415f22b815acbda41abdad36246fe80428c25d499a3b1a1f46e3a76ceb207ee928707c714a56bbf4
)

if("cpp" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/Cpp/FastNoiseLite.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fastnoiselite")
endif()

if("c" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/C/FastNoiseLite.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fastnoiselite-c")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
