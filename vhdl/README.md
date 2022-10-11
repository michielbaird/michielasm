Here is the procedure I followed:

Install yosys:

``
sudo apt-get install build-essential clang bison flex libreadline-dev gawk tcl-dev libffi-dev git graphviz xdot pkg-config python3 libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev
git clone https://github.com/YosysHQ/yosys
cd yosys
make config-gcc
make
sudo make install
``

Install GDHL+Yosys plugin

``
sudo apt install gnat-8
git clone https://github.com/ghdl/ghdl
cd ghdl
./configure --prefix=/usr/local
make
sudo make install
cd ..
git clone https://github.com/ghdl/ghdl-yosys-plugin
cd ghdl-yosys-plugin
make
sudo cp ghdl.so /usr/local/share/yosys/plugins/ghdl.so
``


