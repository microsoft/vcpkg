### Helper to create standardized variables for each nonstd lib
### 
### @param NAME the library's name. Have to match the vcpkg feature name.
### @param REPO the github repo (same as vcpkg)
### @param REF  the commit hash (same as vcpkg)
### @param SHA512 the hash of the downloaded archive (same as vcpkg)
###
### @return 3 Variables:
###             * NONSTD_{NAME}_REPO
###				* NONSTD_{NAME}_REF
###				* NONSTD_{NAME}_SHA512
macro(add_nonstd_library)
	set(oneValueArgs NAME REPO REF SHA512)
	cmake_parse_arguments(NONSTD_LIB "" "${oneValueArgs}" ""
                          ${ARGN} )
						  
    set(NONSTD_${NONSTD_LIB_NAME}_REPO ${NONSTD_LIB_REPO})
	set(NONSTD_${NONSTD_LIB_NAME}_REF ${NONSTD_LIB_REF})
	set(NONSTD_${NONSTD_LIB_NAME}_SHA512 ${NONSTD_LIB_SHA512})			  
endmacro()

### Download from Github and copy include files for one specific nonstd library
###
### @param NAME the feature name. 
macro(nonstd_download_and_install)
	set(oneValueArgs NAME)
	cmake_parse_arguments(NONSTD_LIB "" "${oneValueArgs}" ""
                          ${ARGN})
						  
	vcpkg_from_github(
		OUT_SOURCE_PATH SOURCE_PATH_${NONSTD_LIB_NAME}
		REPO ${NONSTD_${NONSTD_LIB_NAME}_REPO}
		REF  ${NONSTD_${NONSTD_LIB_NAME}_REF}
		SHA512 ${NONSTD_${NONSTD_LIB_NAME}_SHA512}
	)
	
	file(COPY ${SOURCE_PATH_${NONSTD_LIB_NAME}}/include/nonstd DESTINATION ${CURRENT_PACKAGES_DIR}/include)
	
	# Copyright
	if (EXISTS ${SOURCE_PATH_${NONSTD_LIB_NAME}}/LICENSE)
		set(LICENSE_FILE "LICENSE")
		set(LICENSE_PATH  ${SOURCE_PATH_${NONSTD_LIB_NAME}}/LICENSE)
	elseif(EXISTS ${SOURCE_PATH_${NONSTD_LIB_NAME}}/LICENSE.txt)
		set(LICENSE_FILE "LICENSE.txt")
		set(LICENSE_PATH  ${SOURCE_PATH_${NONSTD_LIB_NAME}}/LICENSE.txt)
	else()
		message(WARNING "Cannot find a LICENSE file for ${NONSTD_LIB_NAME} library")
		return()
	endif()
		
	if (LICENSE_PATH)
		file(COPY ${LICENSE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/nonstd)
		file(RENAME ${CURRENT_PACKAGES_DIR}/share/nonstd/${LICENSE_FILE} ${CURRENT_PACKAGES_DIR}/share/nonstd/copyright)
	endif()
	
endmacro()

### NOTE: The NAME have to match the FEATURE's name of vcpkg.

# expected-lite
add_nonstd_library(
	NAME expected
	REPO martinmoene/expected-lite
	# v0.2.0
	REF f7d5f1797a075b51686534c56f8b66e93fbcd7f5
	SHA512 da78385e71d79e77d7600f018f8a6011fe791fda493c059abae7ba551dd64a1725e3d7a3fa013fbd4b2dec93a866db8ae65cd3347bc8030209708208adfb4acd
)

# span-lite
add_nonstd_library(
	NAME span
	REPO martinmoene/span-lite
	# v0.3.0
	REF 76efc9726bc1c362bf8a195f3b04aaf8174c3e22
	SHA512 1db08a1321a6971ab3efdf09dd18e15ffdbdf9bb6ba94e8c0945b83c120e307247fc65213f6ab7ce71871c7530b5c61de068b229614b6d07872c950b6f0c542b
)

# optional-lite
add_nonstd_library(
	NAME optional
	REPO martinmoene/optional-lite
	# v3.1.1
	REF 41ebeb3a6fa36d82b99853409b48af571c6c06dc
	SHA512 85f5b45e5fd9a6497b8eaa3c5a3447e56a942d0f7d83207129a178aa109c545074f14fb4d57726bef38f2ccea205a0f06e5d3a6415ea7403b16bc14a188a0bad
)

# variant-lite
add_nonstd_library(
	NAME variant
	REPO martinmoene/variant-lite
	# v1.1.0
	REF 969bf509853b043ad06084f4259280ec55dd240d
	SHA512 8719af487dedd0fb743419c7918998aba3248a7a106e0a537987cc14cf375936f874be8139f2387f4a106f28e66112052e0760d95ce88da463ed5956cf29adc5
)

# string-view-lite
add_nonstd_library(
	NAME string-view
	REPO martinmoene/string-view-lite
	# v1.0.0
	REF 37bcfc804204e40c688687cd91e4802514dd250a
	SHA512 2b340dc321684e821d028e639d744542b89a34dd6f5d15442ff45b07a7dc11350384a255920c7f9683d81a21ccd04af82b818019e4b65269daee118865679549
)

# byte-lite
add_nonstd_library(
	NAME byte
	REPO martinmoene/byte-lite
	# v0.1.0
	REF 3d7a83f9f50e42caf45f98ab65ad536499345303
	SHA512 15fd50fcf6987be5d62c4a504a91bd1ddcf82ba79ad32eecf1187ce57ea8b43d57d513dfc2309827f500eedd90f8fc528facdde7be1c8967e069e762763a6dc5
)

# any-lite
add_nonstd_library(
	NAME any
	REPO martinmoene/any-lite
	# v0.1.0
	REF ecf78c80318abd7bc379c9aa819945594620e64f
	SHA512 fe54358292de959bda02163e3de5f67ae637ac6911b2840b51223e5ef90211e735f6bd752326bc1b572298757193be18e583fe67c5dcea666115192a87613e0c
)

# observer-ptr
add_nonstd_library(
	NAME observer-ptr
	REPO martinmoene/observer-ptr
	# v0.2.0
	REF cf5e25bb9935606c210a51b45c3418f273fcc02d
	SHA512 4c9b1919ef85da16af5fc56b92a2ca8e8522e78140a93ae908c2e8ea592681bc96b43350a48ff47c90fda6bef40db814f9383f6d3c382bc428c62b7ef88aa641
)

						  