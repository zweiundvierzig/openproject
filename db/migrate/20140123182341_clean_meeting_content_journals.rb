##
# Deletes obsolete entries in meeting_content_journals which have no author assigned,
# but only if a correct row (same journal_id) with an author exists.
# Fails if that is not the case.
class CleanMeetingContentJournals < ActiveRecord::Migration
  def up
    ##
    # The journal entries are doubled in the database.
    # For every journal_id there are two entries:
    #   1) missing meeting and author id but correct text and locked
    #   2) correct meeting and author id but incorrect text and locked
    #
    # This statement will merge the former into the latter.
    update_journals = <<-mysql
      UPDATE meeting_content_journals n
      JOIN meeting_content_journals o
      ON o.journal_id = n.journal_id AND
        n.meeting_id IS NOT NULL AND o.meeting_id IS NULL
      SET
        n.text = o.text,
        n.locked = o.locked;
    mysql

    say "Correcting meeting content journal texts and 'locked'."
    execute(update_journals)

    # This has only been tested against MySQL. The nested select is necessary since you cannot usually
    # delete rows in a table which also appears within the WHERE clause.
    # Deletes the journal entries with missing meeting and author IDs.
    clean_journals = <<-mysql
    DELETE trick.* FROM meeting_content_journals trick
    WHERE author_id IS NULL AND journal_id IN (
      SELECT journal_id FROM (
        SELECT journal_id FROM meeting_content_journals WHERE author_id IS NOT NULL) tmp);
    mysql

    execute(clean_journals)
    debris = execute('SELECT id FROM meeting_content_journals WHERE author_id IS NULL OR meeting_id IS NULL')

    if debris.size > 0
      raise "Clean-up unsuccessful. There is still invalid data left. IDs:\n#{debris.to_a.flatten.join(', ')}"
    else
      say "Successfully cleaned up obsolete meeting content journals or there weren't any."
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "I could recreate the invalid records, but I won't."
  end
end
