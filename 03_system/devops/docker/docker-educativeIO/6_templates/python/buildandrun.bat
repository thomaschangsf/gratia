docker build -t thomaswchang/python-server .
docker push thomaswchang/python-server
docker run --rm -it -p 8089:5000 thomaswchang/python-server
