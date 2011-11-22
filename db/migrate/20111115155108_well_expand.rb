class WellExpand < ActiveRecord::Migration
  def up
    ['mean', 'standard_deviation', 'variance', 'event_count', 'cluster_count', 'mean_cluster2', 'standard_deviation_cluster2', 'variance_cluster2', 'event_count_cluster2'].each do |type_name|
      ct = CharacterizationType.new
      ct.name = type_name
      ct.save!

    end

    add_column :plate_layout_wells, :channel, :string
    add_column :plate_layout_wells, :background, :boolean
    add_column :plate_layout_wells, :reference, :boolean

  end

  def down
  end
end
