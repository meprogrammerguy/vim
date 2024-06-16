#!/bin/bash
( sleep 20; brave http://localhost > /dev/null ) &
sudo -E ssh -i ~/.ssh/id_ed25519 -4 -p 1222 -L localhost:80:192.168.0.1:80 jsmith@b65535-olympic "cat info.txt; pwsh;"
#sudo -E ssh -i ~/.ssh/id_ed25519 -4 -p 1222 -L localhost:80:192.168.0.1:80 jsmith@jsmith-win "cat info.txt; pwsh;"
