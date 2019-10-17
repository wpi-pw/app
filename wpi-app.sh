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
    bash <(curl -s https://raw.githubusercontent.com/wpi-pw/template-workflow/master/wpi-shell.sh) $script
  done
fi

# Run workflow install after setup checking
if [ "$wpi_init_workflow" != "false" ]; then

  # Download default env template or custom from config
  if [ "$wpi_templates_workflow" == "default" ]; then
      curl --silent https://raw.githubusercontent.com/wpi-pw/template-workflow/master/wpi-workflow.sh > tmp-template.sh
  else
      curl --silent $wpi_templates_workflow > tmp-template.sh
  fi

  # If template downloaded, run the script
  if [ -f "${PWD}/tmp-template.sh" ]; then
      bash ${PWD}/tmp-template.sh $1
      # delete the script after complete
      rm ${PWD}/tmp-template.sh
  fi

fi

# Run shell runner after app install
if [ "$wpi_init_shell" == "true" ]; then
  for script in "${wpi_shell_after_install[@]}"
  do
    bash <(curl -s https://raw.githubusercontent.com/wpi-pw/template-workflow/master/wpi-shell.sh) $script
  done
fi
