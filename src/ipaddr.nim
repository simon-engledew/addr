import parseopt, posix, sequtils

type Interface* = object of RootObj
    name*: string
    address*: string
    broadcast*: string
    netmask*: string

type ifaddrs = object
    pifaddrs: ref ifaddrs
    ifa_name: cstring
    ifa_flags: uint
    ifa_addr: ref SockAddr_in
    ifa_netmask: ref SockAddr_in
    ifu_broadaddr: ref SockAddr_in
    ifa_data: pointer

proc getifaddrs(ifap: var ref ifaddrs): int {.header: "<ifaddrs.h>", importc: "getifaddrs".}

proc freeifaddrs(ifap: ref ifaddrs): void {.header: "<ifaddrs.h>", importc: "freeifaddrs".}

proc getInterfaces(): seq[Interface] =
    var interfaceList : ref ifaddrs
    var currentInterface : ref ifaddrs

    result = newSeq[Interface]()

    discard getifaddrs(interfaceList)

    currentInterface = interfaceList

    while currentInterface != nil:
        let address = currentInterface.ifa_addr
        let broadcast = currentInterface.ifu_broadaddr
        let netmask = currentInterface.ifa_netmask
        if address != nil and netmask != nil and broadcast != nil:
            let data = Interface(
                name: $currentInterface.ifa_name,
                address: $inet_ntoa(address.sin_addr),
                broadcast: $inet_ntoa(broadcast.sin_addr),
                netmask: $inet_ntoa(netmask.sin_addr)
            )
            result.add(data)

        currentInterface = currentInterface.pifaddrs

    freeifaddrs(interfaceList)

    return result

proc main() =
    var interfaceNames: seq[string] = @[]
    var interfaceAddrs: seq[string] = @[]
    var interfaces = getInterfaces()

    for kind, key, value in getOpt():
        case kind
        of cmdArgument:
            interfaceNames.add(key)

        of cmdLongOption, cmdShortOption:
            discard

        of cmdEnd:
            discard

    interfaceNames = deduplicate(interfaceNames)

    for iface in interfaces:
        for interfaceName in interfaceNames:
            if interfaceName == iface.name:
                if iface.address != "0.0.0.0" and iface.address != "127.0.0.1":
                    interfaceAddrs.add(iface.address)

    for address in deduplicate(interfaceAddrs):
        echo address


when isMainModule:
    main()
