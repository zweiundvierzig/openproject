##
# Deletes obsolete entries in wiki_content_journals which have no author assigned,
# but only if a correct row (same journal_id) with an author exists.
# Fails if that is not the case.
class CleanWikiContentJournals < ActiveRecord::Migration
  def up
    # This has only been tested against MySQL. The nested select is necessary since you cannot usually
    # delete rows in a table which also appears within the WHERE clause.
    clean_old_journals = <<-mysql
      DELETE trick.* FROM wiki_content_journals trick
      WHERE author_id IS NULL AND journal_id IN (
        SELECT journal_id FROM (
          SELECT journal_id FROM wiki_content_journals WHERE author_id IS NOT NULL) tmp);
    mysql

    execute(clean_old_journals)
    debris = execute('SELECT id FROM wiki_content_journals WHERE author_id IS NULL')

    if debris.size > 0
      raise "Clean-up unsuccessful. There is still invalid data left. IDs:\n#{debris.to_a.flatten.join(', ')}"
    else
      say "Successfully cleaned up obsolete wiki content journals or there weren't any."
    end

    journal_ids = execute("SELECT journal_id FROM wiki_content_journals").to_a.flatten

    say "Correcting #{journal_ids.size} wiki content versions."

    current_yamler = YAML::ENGINE.yamler || 'psych'
    begin
      require 'syck'
      # The change to 'syck' ensures that legacy data is correctly read from
      # the 'legacy_journals' table. Otherwise, we would end up with false
      # encoded data in the new journal.
      YAML::ENGINE.yamler = 'syck'

      journal_ids.each do |journal_id|
        correct_version, correct_text = execute(
          "SELECT version, changed_data FROM legacy_journals WHERE activity_type = 'wiki_edits' AND id = #{journal_id}"
        ).to_a.map do |version, text|
          [version, YAML.load(text)["data"]]
        end.first || raise("Could not find correct journal version and text for #{journal_id}.")

        update = <<-sql
          UPDATE wiki_content_journals
          SET
            lock_version = #{correct_version},
            text = ?
          WHERE journal_id = #{journal_id}
        sql
        execute(ActiveRecord::Base.send(:sanitize_sql_array, [update, correct_text]))
      end
    ensure
      YAML::ENGINE.yamler = current_yamler
    end

    say "Wiki content version correction complete."
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "I could recreate the invalid records, but I won't."
  end
end
