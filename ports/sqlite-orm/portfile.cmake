include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF e8a9e9416f421303f4b8970caab26dadf8bae98b # v1.5
    SHA512 9774345e0209482a137e5f3058e2f27db55ea72fd08c44e67c0989df8927fee896cb789dcb2cd21167689c2f2be1c126bd730a6ea1083a48e6dd58fb048c6f5e
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/sqlite_orm DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-orm RENAME copyright)
