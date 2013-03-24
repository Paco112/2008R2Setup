netsh interface portproxy reset
netsh interface portproxy add v4tov4 listenport=1723 listenaddress=127.0.0.1 connectport=22 connectaddress=192.168.1.1