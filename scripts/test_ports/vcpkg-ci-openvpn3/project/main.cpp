#include <openvpn/ovpncli.hpp>

using namespace openvpn::ClientAPI;

// Cf. https://github.com/OpenVPN/openvpn3/blob/master/README.rst#openvpn-3-client-core
class Client : public OpenVPNClient
{
public:
    void acc_event(const AppCustomControlMessageEvent &) override {}
    void event(const Event&) override {}
    void external_pki_cert_request(ExternalPKICertRequest &) override {}
    void external_pki_sign_request(ExternalPKISignRequest &) override {}
    void log(const LogInfo&) override {}
    bool pause_on_connection_timeout() override { return false; }
};

int main()
{
    Client c;
    return OpenVPNClient::stats_n();
}
