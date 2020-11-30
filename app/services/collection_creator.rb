class CollectionCreator

  def self.find_or_create_collection(collection_name, unit_name, collection_desc, manager_user_key)
    # collection name is stored downcased in solr
    # TODO: check normalization method that fills in name_uniq_si field on Collection create
    collection = Admin::Collection.where(name_uniq_si: collection_name.to_s.downcase.gsub(/\s/, '')).first

    return collection if collection
    Admin::Collection.create!({name: collection_name, unit: unit_name, description: collection_desc, managers: [manager_user_key], default_visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED})
  end
end
