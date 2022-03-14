# single header file library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sharkdp/dbg-macro
    REF 4db61805d90cb66d91bcc56c2703591a0127ed11
    SHA512 68afaedce857f6007edbb65527745aa07ab3dd736e65602b4c6da04646730ef4c09d9a239a9bcae1806c5a0bc0f70b5766edf245b2fd5f84d64cc03a5cadc5c8
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/dbg.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
