vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bfgroup/Lyra
    REF 1.5
    SHA512 1f8e505a487a9421a59afed0ee0c68894fb479117ac20c0bbb8d77ccf50ab938a68c93068f26871b9ddff0a21732d8bb1c6cc997b295a2a39c9363d32e320b3b
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/lyra DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
