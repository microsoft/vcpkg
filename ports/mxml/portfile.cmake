vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO michaelrsweet/mxml
    REF 0d5afc4278d7a336d554602b951c2979c3f8f296 # 4.0.4
    SHA512 3a90d9929b10fb563a8b5dcde67ec766e306397211c1125954064f7ca207d0d246eaf839f9fbf36e049aaab370670b97debc689121ea9f1c9c2edf0ea3a32eb9
    HEAD_REF master
)

# Build:
vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "vcnet/mxml4.vcxproj"
    TARGET Build
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
