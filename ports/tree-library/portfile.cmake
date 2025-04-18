vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ali-Hassan2/Tree-Library
    REF main
    SHA512 b78a86e2cd706a8172079af70ec7187181b7765eda1c3814000ad8aa0c75129941eb14243647243cb2a3ecb8f70a13bff664c2b1d37ca4322361268f5a17b6da



    HEAD_REF master
)


file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")


message(STATUS "✅ Tree Library installed successfully! 🚀")
message(STATUS "📌 Created by: Ali Hassan")
message(STATUS "📍 GitHub: https://github.com/Ali-Hassan2/TreeLibrary")
