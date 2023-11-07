vcpkg_from_github(
        OUT_SOURCE_PATH source
        REPO saadshams/nanojson
        REF 1.0.0
        SHA512 d7ac163455b585ac00fafa3cc6c7090ec39e43b45e95f0d7006e56dcedc7bde05070ad339df48b25ff2e3a545fab96ca80eb5f668fc87557add70c3578bb74ba
        HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
