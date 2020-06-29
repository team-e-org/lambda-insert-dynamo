require 'mysql2'
require 'json'

def lambda_handler(event:, context:)
  json = JSON.parse(event)

  tag_ids = []
  json["tags"].each do |tag|
    tag_ids << tag["id"]
  end

  p select_user_ids(tag_ids)
end

def build_where_clause(tag_ids)
  return "" if tag_ids.length == 0

  where_clause = "WHERE tag_id IN ("
  tag_ids.each_with_index do |id, idx|
    if (idx == tag_ids.length-1)
      where_clause += "#{id})"
    else
      where_clause += "#{id}, "
    end
  end

  where_clause
end

def select_user_ids(tag_ids)
  client = Mysql2::Client.new(host: '127.0.0.1', username: 'test_user', password: 'password', database: 'test_db')

  query = "
    SELECT
      DISTINCT(u.id) AS user_id
    FROM
      pins_tags AS pt
      JOIN pins AS p ON pt.pin_id = p.id
      JOIN users AS u ON p.user_id = u.id
    #{build_where_clause(tag_ids)}
  "

  user_ids = []
  client.query(query).each do |row|
    user_ids << row['user_id']
  end
  user_ids
end
