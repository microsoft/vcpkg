#include <wow64ext.h>
int main()
{
   auto handle = GetModuleHandle64(L"user32.dll");
   return 0;
}
