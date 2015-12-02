class JsonAccessor
  def initialize(store_id)
    @store_id = store_id.downcase
  end

  def access_jsonstore(uid)
    json_stores = JsonStore.where(store_id: @store_id, uid: uid)
    if json_stores.present?
      result = json_stores.first
    else
      result = JsonStore.create(store_id: @store_id, uid: uid, json_str: '{}')
    end
    result
  end

  def clear_entries()
    JsonStore.where(store_id: @store_id).destroy_all
  end

  def count_entries()
    JsonStore.where(store_id: @store_id).count
  end

  def fetch_entries
    results = []
    fetch_uids.each do |uid|
      results << fetch_entry(uid)
    end
    results
  end

  def fetch_entry(uid)
    json_store = access_jsonstore(uid)
    json = JSON.load(json_store.json_str)
    json['uid'] = uid
    json
  end

  def fetch_uids
    JsonStore.where(store_id: @store_id).pluck(:uid)
  end

  def store_entry(uid, json)
    json.delete('uid') unless json.nil?
    json_str = json.nil? ? '{}' : json.to_json
    json_store = access_jsonstore(uid)
    json_store.json_str = json_str
    json_store.save
  end
end