#!/usr/bin/env bash
set -o xtrace
fuel node set --node 00:00 --role controller --env 1
fuel node set --node 00:01 --role compute,cinder --env 1
fuel node set --node 00:02 --role compute,cinder --env 1

echo 'Applying scenario settings'
fuel settings --env 1 --download
/usr/bin/env ruby <<-EORUBY
        require 'yaml'
        config = YAML.load_file('settings_1.yaml')
        config["editable"]["additional_components"]["murano"]["value"] = true
	config["editable"]["additional_components"]["sahara"]["value"] = true
        File.open('settings_1.yaml','w') do |h|
                h.write config.to_yaml
        end
EORUBY

fuel settings --env 1 --upload

set +o xtrace
