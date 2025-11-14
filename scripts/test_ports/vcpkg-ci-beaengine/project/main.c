#include <stdio.h>
#include <beaengine/BeaEngine.h>
int main()
{
   printf("Using BeaEngine version %s-%s.\n", BeaEngineVersion(), BeaEngineRevision());
   return 0;
}
