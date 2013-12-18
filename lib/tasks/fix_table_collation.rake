#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require_relative '../../db/migrate/migration_utils/utils'

namespace :migrations do
  namespace :journals do
    desc "Fixes table collation; you may choose the collation: `rake migrations:journals:fix_table_collation collation=utf8_unicode_ci`"
    task :fix_table_collation => :environment do |task|
      collation = ENV['collation'] || "utf8_general_ci"

      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.execute(
          "ALTER TABLE #{table} CONVERT TO character SET utf8 COLLATE #{collation};")
      end

      puts
      puts "Unified table collations to '#{collation}'."
    end
  end
end
