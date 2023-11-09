vcpkg_from_github(
        OUT_SOURCE_PATH source
        REPO saadshams/nanojson
        REF 1.0.0
        SHA512 2b6c415c5523acb1aea08a3106a0199e4451b5b9837837886698c672246de586701b3076b4686c82b8d72b331f98303a7fb072b029e6a7b899533cea42e6dd96
        HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${source})

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${source}/LICENSE")
