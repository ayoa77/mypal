class UserIndexJob
  @queue = :elasticsearch

  Client = Elasticsearch::Client.new host: 'localhost:9200', retry_on_failure: 20

  def self.perform(operation, user_id, database)

    default_config ||= ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.establish_connection(default_config.dup.update(:database => database))

    case operation.to_s
      when /index/
        user = User.find(user_id)
        Client.index  index: database+"_users", type: 'user', id: user.id, body: user.as_indexed_json
      when /delete/
        Client.delete index: database+"_users", type: 'user', id: user_id
      else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end