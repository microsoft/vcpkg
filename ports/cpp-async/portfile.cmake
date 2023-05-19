vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cpp-async
    REF 8eaf564048d679aef4dec5ae99713903ca4fa829
    SHA512 43e7994952bd80dfc6b4acdd9d1730b6cdf9f3f44a4aa8c12650bdfcac6e733b7267789e64efeb1083a15a6b04131edcfece23c3cd2364894043b0dcc4c553a9
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/async" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
