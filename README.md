# Apt-Cacher NG

[https://www.unix-ag.uni-kl.de/~bloch/acng/](https://www.unix-ag.uni-kl.de/~bloch/acng/)

```sh
docker build -t apt-cacher-ng -f Dockerfile .
docker run -d --cap-drop=all --name apt-cacher-ng -p 3142:3142 apt-cacher-ng
http://DOCKERCONTAINERIP:3142/acng-report.html
```

/etc/apt/apt.conf.d/01proxy:
```sh
Acquire::http::Proxy "http://DOCKERCONTAINERIP:3142";
Acquire::https::Proxy "http://DOCKERCONTAINERIP:3142";
```
