vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/strtk
    REF d9cc24c696ca3aea25d2ac8c2c495e18d7e6cd89 # accessed on 2020-09-14
    SHA512 c37c0df1dd3f7bc1dfcceea83ed9303cf9388ba400ee645f26a24bca50bf85209f7b8a2169f6b98b0267ece986a29a27605ff3eaef50a44629fb7e042d06f26a
)

file(COPY ${SOURCE_PATH}/strtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/strtk)
