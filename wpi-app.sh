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

# Create array of scripts
mapfile -t before_install < <( wpi_yq 'shell.before_install' )
# Run shell runner before app install
if [ "$(wpi_yq init.shell)" == "true" ]; then
  for script in "${before_install[@]}"
  do
    bash <(curl -s $(url_path "template-workflow/wpi-shell")) $script
  done
fi

# Run workflow install after setup checking
if [ "$(wpi_yq init.workflow)" != "false" ]; then
  # current environment
  get_cur_env $1

  # Download and run default workflow template or custom from the config
  template_runner $(wpi_yq templates.workflow) "template-workflow/wpi-workflow" $(wpi_yq init.workflow) $cur_env

  # Download and run default env template or custom from the config
  template_runner $(wpi_yq templates.env) "template-env/env-init" $(wpi_yq init.env) $cur_env

  # Download and run default settings template or custom from the config
  template_runner $(wpi_yq templates.settings) "template-settings/settings-init" $(wpi_yq init.settings) $cur_env

  # Download and run default mu-plugins template or custom from the config
  template_runner $(wpi_yq templates.mu_plugins) "template-mu-plugins/mu-plugins-init" $(wpi_yq init.mu_plugins)

  # Download and run default plugins template or custom from the config
  template_runner $(wpi_yq templates.plugins_single) "template-plugins/plugins-single-init" $(wpi_yq init.plugins) $cur_env

  # Download and run default plugins bulk template or custom from the config
  template_runner $(wpi_yq templates.plugins_bulk) "template-plugins/plugins-bulk-init" $(wpi_yq init.plugins_bulk) $cur_env

  # Download and run default themes template or custom from the config
  template_runner $(wpi_yq templates.theme) "template-theme/theme-init" $(wpi_yq init.theme) $cur_env

  # Download and run default child theme template or custom from the config
  template_runner $(wpi_yq templates.child_theme) "template-child-theme/child-theme-init" $(wpi_yq init.child_theme) $cur_env

  # Download and run default child theme template or custom from the config
  template_runner $(wpi_yq templates.extra) "template-extra/extra-init" $(wpi_yq init.extra)
  
  # Check for wp cli helper file before db reset
  if [ -f "${PWD}/wp_tmp_file.txt" ]; then
    wp db reset --yes --quiet
    rm ${PWD}/wp_tmp_file.txt
  fi  
fi

# Create array of scripts
mapfile -t after_install < <( wpi_yq 'shell.after_install' )
# Run shell runner after app install
if [ "$(wpi_yq init.shell)" == "true" ]; then
  for script in "${after_install[@]}"
  do
    bash <(curl -s $(url_path "template-workflow/wpi-shell")) $script
  done
fi
