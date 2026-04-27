#!/bin/bash
set -euo pipefail

sudo apt purge vim-tiny -y
sudo apt purge vim-common -y

sudo apt autoremove -y