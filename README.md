# devbox
This is an opinionated installer for my development environment
using shell scripts to install packages that I use on a Debian base.

In general it installs the minimal Plasma Desktop (without KDE apps), VS Codium + extensions, 
Python, NodeJS, Java, C#, C, C++, Go, Rust, PHP, Ruby, WASM, Docker, Podman,
drivers/codecs, web browser, file browser, terminal/shell setup, Git, cURL, Zip, 
and theme configurations.

To do a fresh install of my dev environment, I start with a minimal install of Debian Trixie,
installed without a Desktop Environment, with sign-in as root disabled, and then:

`sudo apt install git`

`git clone https://github.com/CollinMcKinney/devbox.git`

`sudo bash devbox/install.sh`
