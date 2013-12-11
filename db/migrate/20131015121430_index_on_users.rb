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

class IndexOnUsers < ActiveRecord::Migration
  def change
    add_index :users, [:type, :login], :length => {:type => 128, :login => 128}
    add_index :users, [:type, :status]
  end
end
