vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThomasMonkman/filewatch
    REF a59891baf375b73ff28144973a6fafd3fe40aa21
    SHA512 9a110b42a499ed7047bb8a79029134943582b388db810974ad6b5f91d1ec720e45a9a3543c4a56ee97d51439f5a34222bada0fb43281dcbc2e65bdee38f836d5
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/FileWatch.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/thomasmonkman-filewatch")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
