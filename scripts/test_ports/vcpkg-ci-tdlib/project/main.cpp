#include <td/telegram/Client.h>
#include <memory>
int main()
{
   std::unique_ptr<td::ClientManager> client_manager_;
   auto response = client_manager_->receive(10);
   return 0;
}
