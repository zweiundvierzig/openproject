#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

##
# In previous versions the indices on the users table were unnecessarily long
# with a length of up to 255 for both type as well as login.
# In 99.9% of the cases the length for both of those fields will be less than 16, however.
#
# Accordingly this migration changes the index length to 16.
# This may degrade performance only if there are a great number of cases where logins are longer than 16
# characters, which is very unlikely.
# The currently known maximum length for the type field is 11.
class SetShortIndexOnUsers < ActiveRecord::Migration
  def up
    remove_index :users, [:type, :login]
    remove_index :users, [:type, :status]

    add_index :users, [:type, :login], :length => {:type => 16, :login => 16}
    add_index :users, [:type, :status]
  end

  def down
    remove_index :users, [:type, :login]
    remove_index :users, [:type, :status]

    add_index :users, [:type, :login], :length => {:type => 128, :login => 128}
    add_index :users, [:type, :status]
  end
end
