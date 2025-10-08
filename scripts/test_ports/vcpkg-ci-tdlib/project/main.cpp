#include <td/telegram/Client.h>
#include <memory>
int main()
{
   std::unique_ptr<td::ClientManager> client_manager_;
   client_manager_.reset();
   return 0;
}
