#!/bin/bash

# WPI APP
# by DimaMinka (https://dima.mk)
# https://github.com/wpi-pw/app

# Get config files and put to array
wpi_confs=()
for ymls in wpi-config/*
do
  wpi_confs+=("$ymls")
done

# Get wpi-source for yml parsing, noroot, errors etc
source <(curl -s https://raw.githubusercontent.com/wpi-pw/template-workflow/master/wpi-source.sh)

# Run shell runner before app install
if [ "$wpi_init_shell" == "true" ]; then
  for script in "${wpi_shell_before_install[@]}"
  do
    bash wpi-shell.sh $script
  done
fi