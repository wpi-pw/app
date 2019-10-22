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
    bash <(curl -s $(url_path "template-workflow/wpi-shell")) $script
  done
fi

# Run workflow install after setup checking
if [ "$wpi_init_workflow" != "false" ]; then
  # current environment
  get_cur_env $1

  # Download and run default workflow template or custom from the config
  template_runner $wpi_templates_workflow "template-workflow/wpi-workflow" $wpi_init_workflow $cur_env

  # Download and run default env template or custom from the config
  template_runner $wpi_templates_env "template-env/env-init" $wpi_init_env $cur_env

  # Download and run default settings template or custom from the config
  template_runner $wpi_templates_settings "template-settings/settings-init" $wpi_init_settings $cur_env

  # Download and run default mu-plugins template or custom from the config
  template_runner $wpi_templates_mu_plugins "template-mu-plugins/mu-plugins-init" $wpi_init_mu_plugins

  # Download and run default mu-plugins template or custom from the config
  template_runner $wpi_templates_plugins "templateplugins/plugins-single-init" $wpi_init_plugins
fi

# Run shell runner after app install
if [ "$wpi_init_shell" == "true" ]; then
  for script in "${wpi_shell_after_install[@]}"
  do
    bash <(curl -s $(url_path "template-workflow/wpi-shell")) $script
  done
fi
