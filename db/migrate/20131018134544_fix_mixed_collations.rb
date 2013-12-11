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
# This migration is supposed to fix the following error that may occur during migration:
#
#     ==  AddMissingAttachableJournals: migrating ===================================
#     -- Add missing attachable journals
#     rake aborted!
#     An error has occurred, all later migrations canceled:
#
#     Mysql2::Error: Illegal mix of collations (utf8_general_ci,IMPLICIT) and (utf8_unicode_ci,IMPLICIT) for operation '=':         SELECT * FROM (
#           SELECT a.container_id AS journaled_id, a.container_type AS journaled_type, a.id AS attachment_id, a.filename, MAX(aj.id) AS aj_id, MAX(j.version) AS last_version
#           FROM attachments AS a JOIN journals AS j
#             ON (a.container_id = j.journable_id AND a.container_type = j.journable_type) LEFT JOIN attachable_journals AS aj
#             ON (a.id = aj.attachment_id)
#           GROUP BY a.container_id, a.container_type, a.id, a.filename
#           ) AS tmp
#         WHERE aj_id IS NULL
#
class FixMixedCollations < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE attachments CONVERT TO character SET utf8 COLLATE utf8_unicode_ci;'
    execute 'ALTER TABLE custom_values CONVERT TO character SET utf8 COLLATE utf8_unicode_ci;'
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "Previous collations for attachments and custom_values unknown. Probably utf8_general_ci, though."
  end
end
