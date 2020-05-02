import ipaddress
import sys
args = sys.argv
network_file_path = args[1]
ip_file_path = args[2]
result_file_path = args[3]

def load_data(path, func):
    with open(path, 'r') as f:
        container = []
        for line in f.readlines():
            container.append(func(line.strip()))
    return container

str_to_network = lambda x:ipaddress.ip_network(x)
str_to_ip = lambda x:ipaddress.ip_address(x)

network_file_path = load_data(network_file_path, str_to_network)
ip_file_path = load_data(ip_file_path, str_to_ip)


ip_with_network = []
for ip in ip_file_path:
    result = (ip,'network not find')
    for network in network_file_path:
        if ip in network:
            result = (ip, network)
            break
    ip_with_network.append(result)

with open(result_file_path, 'w') as f:
    for ip in ip_with_network:
        f.write('{}, {}\n'.format(str(ip[0]), str(ip[1])))