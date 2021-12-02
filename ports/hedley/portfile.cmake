# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/hedley
    REF 8fb0604a8095f6c907378cc3f0391520ae843f6f
    SHA512 3ce102d348f96bd8c7d44bc7119a8f637041f613e1e6a578c15e24c56f79dbcb0b1bce93bc8779a90cc2e34ab74d09f29d240b4519d592973c59da49923460da
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/hedley.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(STRINGS ${SOURCE_PATH}/hedley.h SOURCE_LINES)
# Capture more lines than required to handle future license file changes
list(SUBLIST SOURCE_LINES 0 30 SOURCE_LINES)
list(JOIN SOURCE_LINES "\n" _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${_contents}")
