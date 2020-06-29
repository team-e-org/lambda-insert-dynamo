require 'mysql2'
require 'aws-sdk'

def lambda_handler(event:, context:)
  tag_ids = []
  event["tags"].each do |tag|
    tag_ids << tag["id"]
  end

  insert_dynamo(event['pin'], select_user_ids(tag_ids))
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
  client = Mysql2::Client.new(
    host: ENV['MYSQL_HOST'],
    username: ENV['MYSQL_USER'],
    password: ENV['MYSQL_PASSWORD'],
    database: ENV['MYSQL_DATABASE'],
    port: ENV['MYSQL_PORT']
  )

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

def insert_dynamo(pin, user_ids)
  dynamoDB = Aws::DynamoDB::Resource.new(region: 'ap-northeast-1')
  table = dynamoDB.table('home-pins')

  user_ids.each do |user_id|
    table.put_item({
      item:
        {
          "user_id": user_id,
          "pin_id": pin['id'],
          "title": pin['title'],
          "description": pin['description'],
          "post_user_id": pin['userId'],
          "image_url": pin['imageUrl'],
          "is_private": pin['isPrivate'],
          "created_at": pin['createdAt'],
          "updated_at": pin['updatedAt']
        }
      })
  end
end
