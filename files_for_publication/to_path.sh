#!/usr/bin/env bash
gs -o $2 -dNoOutputFonts -sDEVICE=eps2write -dEPSCrop $1
