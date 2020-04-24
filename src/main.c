#include <ifaddrs.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>

#define hasprefix(s, prefix) strncmp(prefix, s, sizeof prefix - 1) == 0

int main(int argc, char **argv)
{
  struct ifaddrs *ifaddrs, *ifaddr;

  char *address = NULL;
  char *match = NULL;

  static char fallback[16];

  if (getifaddrs(&ifaddrs) == 0)
  {
    for (ifaddr = ifaddrs; ifaddr != NULL && match == NULL; ifaddr = ifaddr->ifa_next)
    {
      int n = 1;

      do
      {
        if (argc == 1 || strcmp(ifaddr->ifa_name, argv[n]) == 0)
        {
          if (ifaddr->ifa_addr == NULL || ifaddr->ifa_netmask == NULL)
          {
            continue;
          }

          address = inet_ntoa(((struct sockaddr_in *)ifaddr->ifa_addr)->sin_addr);

          if (hasprefix(address, "172.16."))
          {
            strncpy(fallback, address, sizeof(fallback));

            continue;
          }

          if (strcmp(address, "0.0.0.0") == 0 || strcmp(address, "127.0.0.1") == 0)
          {
            continue;
          }

          match = address;

          break;
        }
      } while (++n < argc);
    }

    freeifaddrs(ifaddrs);
  }

  printf("%s\n", match == NULL ? (strlen(fallback) == 0 ? "127.0.0.1" : fallback) : match);
}
