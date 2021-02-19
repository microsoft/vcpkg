vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lieff/minimp3
    REF 95864e8e0d3b34402a49ae9af6c66f7e98c13c35 #committed on Nov 27
    SHA512 6e5364a83e882b54fd1eb5ba35ec7c7179b5b5c0ceb2c658615a2306ae0c28252ca8591ec6b515483c6ff0ed608db7eb73fba3d201a20ad4a85ce7b3a091a695
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/minimp3.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/minimp3_ex.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)