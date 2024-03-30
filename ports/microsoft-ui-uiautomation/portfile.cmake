# portfile.cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/Microsoft-UI-UIAutomation
    REF d8c87fae212678915d9b73505e188c3b63db0d79
    SHA512 4266d5f236ee7f4e2daf02177544876f025b6ec04e9ce0ad63afd0c4674ef1411865a9188d6a8a3a13b64bab1da70bebba25f03b3fc1bf39272f0c04bcbbe28f
    HEAD_REF main
)

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}/src/UIAutomation/"
    PROJECT_SUBPATH "UIAutomation.sln"
    OPTIONS
        "/r:True"
	    "/p:RestorePackagesConfig=True"
        "/p:Platform=Win32"
)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")