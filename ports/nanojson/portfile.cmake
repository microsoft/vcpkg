vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO saadshams/nanojson
        REF 1.0.0
        SHA512 beb1017eb5242f98d49d39421da92dce6ca4f93d831223070ba48fd69375a6289b281226f14a148945c431b825dbb71c08fc0c288570dcdaa547af3531864d54
        HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
