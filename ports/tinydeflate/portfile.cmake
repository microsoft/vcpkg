vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bisqwit/TinyDeflate
    REF 68ced8bd5c819264e628d4f063500753b77f613d
    SHA512 1555adc1caa26383110c680806af5b2011ea192fbe9c45479c5622cf6b4a51685f3bf1bdfa530ff6ca5e55871e8b6781516edb90dad5a5b4265b67bb53966a2d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/gunzip.hh" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
