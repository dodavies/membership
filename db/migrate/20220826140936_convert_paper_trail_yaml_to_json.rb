class ConvertPaperTrailYamlToJson < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute('LOCK TABLE versions WRITE')
      PaperTrail::Version.where.not(object: nil).find_each do |version|
        version.update_column(:new_object, YAML.load(version.object))
        if version.object_changes
          version.update_column(:new_object_changes, YAML.load(version.object_changes))
        end
      end
      ActiveRecord::Base.connection.execute('UNLOCK TABLES')
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
