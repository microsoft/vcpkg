# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF fb228e0a107f90c60c904292feb1a270fd601a70 # 3.0
    SHA512 478b253f9400d2304eaaa9d7dc2dc7757706dbfde1fc842dffa823417f0a8c36fba1ce5136bb7ac1ac6825935846f54242855f4b2978db1292a3ee0f65c584d6
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/Source/LuaBridge
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
configure_file(
    ${SOURCE_PATH}/README.md
    ${CURRENT_PACKAGES_DIR}/share/luabridge/copyright
    COPYONLY
)
