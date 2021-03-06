# Copyright (C) 2017 Battelle Memorial Institute
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD-2 license.  See the LICENSE file for details.
# frozen_string_literal: true
require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/ovirt_helpers'
require 'chef/knife/cloud/ovirt_service_options'

class Chef
  class Knife
    class Cloud
      class OvirtVolumeList < ResourceListCommand
        include OvirtHelpers
        include OvirtServiceOptions

        banner 'knife ovirt volume list (options)'

        def query_resource
          @service.connection.list_volumes
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end

        def list(volumes)
          volume_list = [
            ui.color('ID', :bold),
            ui.color('Name', :bold),
            ui.color('Size', :bold),
            ui.color('Status', :bold),
          ]
          begin
            volumes.each do |volume|
              volume_list << volume[:id]
              volume_list << volume[:name]
              volume_list << humanize(volume[:size])
              volume_list << volume[:status]
              # There is a description field too, but it doesent seem to be available through fog.
            end
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
          puts ui.list(volume_list, :uneven_columns_across, 4)
        end
      end
    end
  end
end
