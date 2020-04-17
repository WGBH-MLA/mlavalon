class CollectionCreator

  def self.find_or_create_collection(collection_name, unit_name, collection_desc, manager_email='woo@foo.edu')
    collection = Admin::Collection.where(name_uniq_si: collection_name).first

    return collection if collection
    Admin::Collection.create({name: collection_name, unit: unit_name, description: collection_desc, managers: [manager_email]})
  end


end