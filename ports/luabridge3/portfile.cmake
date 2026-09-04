# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF 53e031b7df6a14d43f92a54fd792b76dbadcc970 # 3.0-rc12
    SHA512 0e07beddf2c48e4ad48733ca8d0d6dded6b23bc670ccf887cf21e468ccdc06e78fae1966c07cfee06fd4d8452c0abc91a9df6542cc4837fe0d11d1cd73e9b1a8
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
