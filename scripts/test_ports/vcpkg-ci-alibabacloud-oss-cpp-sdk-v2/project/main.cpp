#include <alibabacloud/oss2/ClientConfiguration.h>
#include <alibabacloud/oss2/OSSClient.h>
#include <alibabacloud/oss2/credentials/CredentialsProvider.h>
#include <boost/beast/core/detail/base64.hpp>
#include <tinyxml2.h>

#include <cstring>
#include <memory>
#include <string>

#if defined(HAS_LEGACY_OSS_SDK)
#include <alibabacloud/oss/OssClient.h>
#include <alibabacloud/oss/client/ClientConfiguration.h>
#endif

int main() {
    tinyxml2::XMLDocument doc;
    if (doc.Parse("<root answer='42' />") != tinyxml2::XML_SUCCESS) {
        return 1;
    }

    const auto* root = doc.FirstChildElement("root");
    if (!root) {
        return 1;
    }

    char encoded_buffer[16] = {};
    const auto encoded_size = boost::beast::detail::base64::encode(encoded_buffer, "oss", 3);
    const std::string encoded(encoded_buffer, encoded_size);

    alibabacloud::oss2::ClientConfiguration v2_config;
    v2_config.region = "cn-hangzhou";
    v2_config.credentialsProvider = std::make_shared<alibabacloud::oss2::StaticCredentialsProvider>(
        "access-key-id", "access-key-secret");

    alibabacloud::oss2::OSSClient v2_client(v2_config);
    (void)v2_client;

#if defined(HAS_LEGACY_OSS_SDK)
    AlibabaCloud::OSS::InitializeSdk();
    AlibabaCloud::OSS::ClientConfiguration legacy_config;
    AlibabaCloud::OSS::OssClient legacy_client(
        "oss-cn-hangzhou.aliyuncs.com",
        "access-key-id",
        "access-key-secret",
        legacy_config);
    const auto legacy_md5 = AlibabaCloud::OSS::ComputeContentMD5("oss", 3);
    AlibabaCloud::OSS::ShutdownSdk();

    return encoded == "b3Nz" && std::strcmp(root->Name(), "root") == 0 && legacy_md5.size() == 32 ? 0 : 1;
#else
    return encoded == "b3Nz" && std::strcmp(root->Name(), "root") == 0 ? 0 : 1;
#endif
}
