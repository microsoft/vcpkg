vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookarchive/KVOController
    REF 60b3ccb966cb3ac3a9d0957bc5f88f2f8efad239 #v1.2.0
    SHA512 45563cb96d157e21e53c8b92ab117f00270b71ca515235a0c99f4ab6b91ef5e029204a1f13a6b9f1f26a7c490e80089aa9d062a78bf8bb14ab3be173ebbf0bfd
    HEAD_REF master
)

vcpkg_xcode_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_FILE FBKVOController.xcodeproj
)

message(FATAL_ERROR)