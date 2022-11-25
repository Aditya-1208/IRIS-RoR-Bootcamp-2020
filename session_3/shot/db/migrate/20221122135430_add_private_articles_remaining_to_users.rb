class AddPrivateArticlesRemainingToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :private_articles_remaining, :int, default: 3
  end
end
