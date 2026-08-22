vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO orlp/pdqsort
	REF 08879029ab8dcb80a70142acb709e3df02de5d37
	SHA512 38e8b6e35edf1e88e26850a13ce892d8adc0d3e1d7954287d024b3bb858a6b2284e25fbf7c92a694b3ec77cacaf6bbc27fc365187115f7cca6bc88088f67a18f
	HEAD_REF master
)

file(COPY ${SOURCE_PATH}/pdqsort.h  DESTINATION ${CURRENT_PACKAGES_DIR}/include/pdqsort)

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt ${SOURCE_PATH}/readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/pdqsort)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pdqsort/license.txt ${CURRENT_PACKAGES_DIR}/share/pdqsort/copyright)