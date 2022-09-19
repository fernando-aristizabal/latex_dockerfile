#!/bin/bash

umask 002
id
newgrp $GN
exec "$@"
