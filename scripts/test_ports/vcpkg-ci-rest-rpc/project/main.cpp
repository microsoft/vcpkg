#include <rest_rpc.hpp>

int main()
{
    rest_rpc::rpc_client client("127.0.0.1", 8080);
	client.connect();
	client.run();
    return 0;
}
