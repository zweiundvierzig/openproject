#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

##
# Applies the 'rails_relative_url_root' to the routing table.

[OpenProject::Configuration["rails_relative_url_root"]].compact.each do |root|
  scope = OpenProject::Application.routes.default_scope

  if scope
    OpenProject::Application.routes.default_scope = File.join(root, scope)
  else
    OpenProject::Application.routes.default_scope = root
  end

  puts "\n[info] Prepending #{root} to all routes (including shallow ones) as configured through 'rails_relative_url_root'."
end

module ActionDispatch
  module Routing
    class Mapper
      module Scoping
        def scope_with_subdirectory(*args, &block)
          root = OpenProject::Configuration["rails_relative_url_root"]
          options = args.extract_options!

          if root && options[:shallow]
            path = options[:shallow_path]
            if path
              unless path =~ /^#{root}/
                options[:shallow_path] = File.join(root, path)
              end
            else
              options[:shallow_path] = root
            end
          end

          args.push(options)
          scope_without_subdirectory(*args, &block)
        end

        alias_method_chain :scope, :subdirectory
      end
    end
  end
end
