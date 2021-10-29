step 1, download and compiled jemalloc4p
git clone https://github.com/jemalloc/jemalloc
cd jemalloc
./autoconf
./configure
make -j4
sudo make install PREFIX=/usr/lib

cd ..
step 2, download zserver4d
git clone https://github.com/PassByYou888/ZServer4D.git
