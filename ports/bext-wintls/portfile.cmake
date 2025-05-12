vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO laudrup/boost-wintls
    REF "v${VERSION}"
    SHA512 09fda0e2f1b212137c75fa58bd9f4d8df8469fb1381c82c639db9de54ab187119743534e117bd5421329d5c578a21546c4448042f0cad810e73e3a999be5c6db
    HEAD_REF master
)

if(EXISTS "${SOURCE_PATH}/include/wintls")
    file(COPY "${SOURCE_PATH}/include/wintls/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/wintls/")
else()
    message(FATAL_ERROR "Directory ${SOURCE_PATH}/include/wintls does not exist")
endif()

if(EXISTS "${SOURCE_PATH}/include/wintls.hpp")
    file(COPY "${SOURCE_PATH}/include/wintls.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")
else()
    message(FATAL_ERROR "File ${SOURCE_PATH}/include/wintls.hpp does not exist")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")