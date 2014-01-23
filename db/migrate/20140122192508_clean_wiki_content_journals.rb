##
# Deletes obsolete entries in wiki_content_journals which have no author assigned,
# but only if a correct row (same journal_id) with an author exists.
# Fails if that is not the case.
class CleanWikiContentJournals < ActiveRecord::Migration
  def up
    # This has only been tested against MySQL and for some reason after it 963 rows out of >8000 are left
    # even though the delete was supposed to affect only 693 rows  ????
    clean_journals = <<-mysql
    DELETE trick.* FROM wiki_content_journals trick
    WHERE author_id IS NULL AND journal_id IN (
      SELECT journal_id FROM (
        SELECT journal_id FROM wiki_content_journals WHERE author_id IS NOT NULL) tmp);
    mysql

    execute(clean_journals)
    debris = execute('SELECT id FROM wiki_content_journals WHERE author_id IS NULL')

    if debris.size > 0
      raise "Clean-up unsuccessful. There is still invalid data left. IDs:\n#{debris.to_a.flatten.join(', ')}"
    else
      puts "Successfully cleaned up obsolete wiki_content_journals entries or there weren't any."
    end
  end

  def down

  end
end
